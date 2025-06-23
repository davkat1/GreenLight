# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.17.1
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# %% [markdown]
# # Example for running greenlight, displaying and analyzing simulation results
#
# `GreenLight/notebooks/greenlight_example`<br>
# Copyright (c) 2025 David Katzin, Wageningen Research Foundation<br>
# SPDX-License-Identifier: BSD-3-Clause-Clear<br>
# https://github.com/davkat1/GreenLight
#
# Note: a script version of this notebook is available at scripts/greenlight_example.py

# %% [markdown]
# ## Running greenlight

# %%
"""
General imports and settings
"""
# %load_ext autoreload
# %autoreload 2

import os
import sys
import pandas as pd
import matplotlib.pyplot as plt

# Set up directories
project_dir = os.path.abspath(os.path.join(os.path.abspath(""), ".."))
sys.path.append(project_dir)
from greenlight import GreenLight

# Base directory to be used by the model
base_path = os.path.join(project_dir, "models")

# Location (relative to base_path) of the main definition of the Katzin 2021 model, which will be used here
model = os.path.join("katzin_2021", "definition", "main_katzin_2021.json")

# Outputs will be placed under katzin_2021/output
output_dir = os.path.join("katzin_2021", "output")

print(f"Base path: {base_path}\nModel location: {model}\nOutput location: {output_dir}")

# %%
"""
Simulation settings
"""
# Numbers of days to simulate - use a low number for fast simulations
n_days = 10
options = {
    "options": {"t_end": str(n_days * 24 * 3600)}
}

# Any other modification to the model
mods = [{"thetaLampMax": {"definition": "120"}}]  # Change the maximum lamp intensity to 120 W/m2

print(f"Number of days to simulate: {n_days}\nOther mods: {mods}")

# %%
"""
Add weather data
"""
# If there is weather data available, it can be added here

# Location of weather file, relative to base_path
weather_file_directory = os.path.join("katzin_2021", "input_data", "energyPlus_formatted")
weather_file_name = "weather_ams_katzin_2021_from_sep_27_000000.csv"
print(f"Weather file location: {os.path.join(weather_file_directory, weather_file_name)}")

# If the file exists where it's expected, include it in the simulation
if os.path.isfile(os.path.abspath(os.path.join(base_path, weather_file_directory, weather_file_name))):
    mods.append(os.path.join(weather_file_directory, weather_file_name))
print(f"Modifications: {mods}")


# %%
"""
Set location of output file
"""
output_file_name = "greenlight_example.csv"

# %%
"""
Run the model
"""
input_arg = [model, options, mods]
output_arg = os.path.join(output_dir, output_file_name)
mdl = GreenLight(base_path=base_path, input_prompt=input_arg, output_path=output_arg)
mdl.run()

# %% [markdown]
# ## Load, show, and interpret results

# %%
"""
Load simulation result
"""
output_df = pd.read_csv(os.path.join(base_path, output_dir, output_file_name), header=None, low_memory=False)
variable_names = output_df.iloc[0]
descriptions = output_df.iloc[1]
units = output_df.iloc[2]

# Reformat the DataFrame with variable names as columns
output_df = output_df.iloc[3:].reset_index(drop=True).apply(pd.to_numeric)
output_df.columns = variable_names

# Create dictionaries for descriptions and units
descriptions_dict = dict(zip(variable_names, descriptions))
units_dict = dict(zip(variable_names, units))

print(output_df.head(5))

# %%
"""
Choose variables to show
"""
# Choose variables out of output_df.columns
# For a description of a variable var, see descriptions_dict[var]. For the unit, see units_dict[var]
chosen_vars = ["tOut", "tAir", "tCan", "qLampIn", "cFruit", "mcFruitHar", "hBoilPipe", "hBoilGroPipe"]

for var in chosen_vars:
    print(f"{var}: {descriptions_dict[var]} ({units_dict[var]})")


# %%
"""
Show some graphs
"""
# Choose variables out of output_df.columns
# For a description of a variable var, see descriptions_dict[var]. For the unit, see units_dict[var]
chosen_vars = ["tOut", "tAir", "tCan", "qLampIn", "cFruit", "mcFruitHar", "hBoilPipe", "hBoilGroPipe"]

for var in chosen_vars:
    output_df.plot(x="Time", y=var, xlabel="Time (s)", ylabel=f"{var} ({units_dict[var]})", title=descriptions_dict[var], legend=None);


# %%
"""
Calculate yield, energy use, CO2 use, water use
"""
# The time steps (in s) in the output data
time_step = output_df.loc[1,"Time"] - output_df.loc[0,"Time"]
print(f'Time step size: {time_step} seconds')
print(f'Simulation length: {(output_df["Time"].iloc[-1] - output_df["Time"].iloc[0])/86400} days')

# Assumed fruit dry matter content
dmc = 0.06

# Total yield, kg fresh weight per m**2
tot_yield = time_step*sum(output_df["mcFruitHar"])*1e-6/dmc
print(f"Yield: {tot_yield} kg/m2")

# Energy for heating, MJ m**2
energy_heat = time_step*(sum(output_df["hBoilPipe"]) + sum(output_df["hBoilGroPipe"]))*1e-6
print(f"Energy used for heating: {energy_heat} MJ/m2")

# Energy for lighting, MJ m**2
energy_light = time_step*(sum(output_df["qLampIn"]) + sum(output_df["qIntLampIn"]))*1e-6
print(f"Energy used for lighting: {energy_light} MJ/m2")


# Total CO2 use (for CO2 injection), kg m**2
tot_co2 = time_step*sum(output_df["mcExtAir"])*1e-6
print(f"CO2 use: {tot_co2} kg/m2")

# Assumed ratio between total transpiration and total irrigation
# If drain is recirculated, transpiration is about 90% of irrigation, irrigation is about 1.1 times transpiration
trans_to_irrig = 1.1
# Total water use (for irrigation), kg m**2
tot_h20 = time_step*trans_to_irrig*sum(output_df["mvCanAir"])
print(f"Water use for irrigation: {tot_h20} liters/m2")
