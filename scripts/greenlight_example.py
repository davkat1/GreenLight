"""
GreenLight/scripts/greenlight_example.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

An example script on how to use greenlight to run a greenhouse simulation, then view and analyze some of the results.
Note: in order to get meaningful results, weather data (such as EnergyPlus data) should be included.
The same procedure that works for the main program also applies here,
see docs/input_data.md#acquiring-input-data-for-the-greenlightmain-program

A Jupyter Notebook version of this script is available at notebooks/greenlight_example
"""

import datetime as dt
import os
import sys
import warnings

import matplotlib
import pandas as pd

import greenlight

# Detect headless environment and set backend accordingly
if not os.environ.get("DISPLAY"):
    matplotlib.use("Agg")  # Headless (no display)
else:
    matplotlib.use("TkAgg")  # Interactive

import matplotlib.pyplot as plt  # noqa: E402

# Model simulation settings
output_file_name = "greenlight_example_output.csv"  # Chosen name for the file that will contain the simulation output
original_energyPlus_csv = "NLD_Amsterdam.062400_IWECEPW.csv"  # Name of the unprocessed EnergyPlus CSV
formatted_csv_name = "weather_ams_katzin_2021.csv"  # Chosen name for the processed EnergyPlus data
start_date = dt.datetime(year=2020, month=9, day=27)  # First day of simulation season
simulation_length = 3  # Length of simulated season, in days

# Set up directories
if "__file__" in locals():  # Running this from script
    project_dir = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
else:
    project_dir = os.getcwd()  # Most likely the active directory is the project directory
sys.path.append(project_dir)

# Base directory to be used by the model
base_path = os.path.join(project_dir, "greenlight", "models")

# Location (relative to base_path) of the main definition of the Katzin 2021 model, which will be used here
model = os.path.join("katzin_2021", "definition", "main_katzin_2021.json")

# Location of weather files, relative to base_path
original_file_directory = os.path.join("katzin_2021", "input_data", "energyPlus_original")
formatted_file_directory = os.path.join("katzin_2021", "input_data", "energyPlus_formatted")

# Modify directories to absolute path
original_file_directory = os.path.abspath(os.path.join(base_path, original_file_directory))
formatted_file_directory = os.path.abspath(os.path.join(base_path, formatted_file_directory))

# Outputs will be placed under katzin_2021/output
output_dir = os.path.join("katzin_2021", "output")

""" Simulation settings """
# Numbers of days to simulate, in seconds
options = {"options": {"t_end": str(simulation_length * 24 * 3600)}}

# Any other modification to the model
mods = [{"thetaLampMax": {"definition": "120"}}]  # Change the maximum lamp intensity to 120 W/m2

""" Add weather data """
# Convert original file into formatted file - with the required start and end date

# Weather data to use in case formatting the input weather data doesn't work
fallback_directory = os.path.abspath(os.path.join(base_path, os.path.join("katzin_2021", "input_data", "test_data")))
fallback_file = "Bleiswijk_from_20091020.csv"
try:
    formatted_file_name = greenlight.convert_energy_plus(
        os.path.join(original_file_directory, original_energyPlus_csv),
        os.path.join(formatted_file_directory, formatted_csv_name),
        t_out_start=start_date,
        t_out_end=start_date + dt.timedelta(days=simulation_length),
    )
except FileNotFoundError:
    warnings.warn(
        "Couldn't find file:\n"
        f"{os.path.abspath(os.path.join(original_file_directory, original_energyPlus_csv))}\n"
        "Using built-in weather data instead"
    )

    # Use built-in weather data
    formatted_file_directory = fallback_directory
    formatted_file_name = fallback_file
except Exception:
    warnings.warn(
        "Failed to convert EnergyPlus file:\n"
        f"{os.path.abspath(os.path.join(original_file_directory, original_energyPlus_csv))}\n"
        "To formatted file:\n"
        f"{os.path.abspath(os.path.join(formatted_file_directory, formatted_csv_name))}\n"
        "Using built-in weather data instead"
    )

    # Use built-in weather data
    formatted_file_directory = fallback_directory
    formatted_file_name = fallback_file


# Include the generated file in the simulation
mods.append(os.path.join(formatted_file_directory, formatted_file_name))


"""Run the model"""
input_arg = [model, options, mods]
output_arg = os.path.join(output_dir, output_file_name)
mdl = greenlight.GreenLight(base_path=base_path, input_prompt=input_arg, output_path=output_arg)
mdl.run()

"""Load simulation result"""
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

"""Show some graphs"""
# Choose variables out of output_df.columns
# For a description of a variable var, see descriptions_dict[var]. For the unit, see units_dict[var]
chosen_vars = ["tOut", "tAir", "tCan", "qLampIn", "lai", "cFruit", "mcFruitHar", "hBoilPipe", "hBoilGroPipe"]

for var in chosen_vars:
    fig, ax = plt.subplots()
    output_df.plot(
        x="Time",
        y=var,
        xlabel="Time (s)",
        ylabel=f"{var} ({units_dict[var]})",
        title=descriptions_dict[var],
        legend=None,
        ax=ax,
    )
    import errno

    # Check if running in headless mode (no display)
    headless = matplotlib.get_backend().lower() == "agg"

    if headless:
        # Generate the plots in /plots folder instead of showing them

        # Save plots to the same directory as the output file
        plots_dir = os.path.join(base_path, output_dir, "plots")
        try:
            os.makedirs(plots_dir, exist_ok=True)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise
        plot_path = os.path.join(plots_dir, f"{var}.png")
        fig.savefig(plot_path)
        print(f"Plot for {var} saved to {plot_path}")
    else:
        plt.show()

""" Calculate yield, energy use, CO2 use, water use """
# The time steps (in s) in the output data
time_step = output_df.loc[1, "Time"] - output_df.loc[0, "Time"]
print(f"Time step size: {time_step} seconds")
print(f'Simulation length: {(output_df["Time"].iloc[-1] - output_df["Time"].iloc[0]) / 86400} days')

# Assumed fruit dry matter content
dmc = 0.06

# Total yield, kg fresh weight per m**2
tot_yield = time_step * sum(output_df["mcFruitHar"]) * 1e-6 / dmc
print(f"Yield: {tot_yield} kg/m2")

# Energy for heating, MJ m**2
energy_heat = time_step * (sum(output_df["hBoilPipe"]) + sum(output_df["hBoilGroPipe"])) * 1e-6
print(f"Energy used for heating: {energy_heat} MJ/m2")

# Energy for lighting, MJ m**2
energy_light = time_step * (sum(output_df["qLampIn"]) + sum(output_df["qIntLampIn"])) * 1e-6
print(f"Energy used for lighting: {energy_light} MJ/m2")

# Total CO2 use (for CO2 injection), kg m**2
tot_co2 = time_step * sum(output_df["mcExtAir"]) * 1e-6
print(f"CO2 use: {tot_co2} kg/m2")

# Assumed ratio between total transpiration and total irrigation
# If drain is recirculated, transpiration is about 90% of irrigation, irrigation is about 1.1 times transpiration
trans_to_irrig = 1.1

# Total water use (for irrigation), kg m**2
tot_h20 = time_step * trans_to_irrig * sum(output_df["mvCanAir"])
print(f"Water use for irrigation: {tot_h20} liters/m2")
