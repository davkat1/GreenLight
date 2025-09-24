"""
GreenLight/scripts/katzin_2020/katzin_2020_generate_output.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Script for generating Tables 3-4 and Figures 5-7 published in Katzin (2020),
which also appeared as Katzin (2021) Chapter 3.

This script assumes that katzin_2020_run_sims.py has been run successfully, and that the output files are in
models/katzin_2021/output

It also assumes that the data from Katzin (2020) is in models/katzin_2021/input_data/katzin_2020_original
To do this, first the old data files must be acquired from:
    https://data.4tu.nl/datasets/78968e1b-eaea-4f37-89f9-2b98ba3ed865
    Download the file "Processed data.zip", unzip it, and copy the CSV files in the folder to:
    models/katzin_2021/input_data/katzin_2020_original


References:
    Katzin, D., van Mourik, S., Kempkes, F., & van Henten, E. J. (2020). GreenLight – An open source model for
        greenhouses with supplemental lighting: Evaluation of heat requirements under LED and HPS lamps.
        Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010
    Katzin, D. (2021). Energy Saving by LED Lighting in Greenhouses : A Process-Based Modelling Approach.
        PhD thesis, Wageningen University. https://doi.org/10.18174/544434
"""

import os
import sys

import pandas as pd
from _katzin_2020_generate_figures import generate_fig_5, generate_fig_6, generate_fig_7
from _katzin_2020_generate_tables import generate_table_3, generate_table_4

import scripts.analyze_output as ao

"""Set up directories"""
if "__file__" in locals():  # Running this from script
    project_dir = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../.."))
else:
    project_dir = os.getcwd()  # Most likely the active directory is the project directory
sys.path.append(project_dir)

# Location of simulation outputs
output_dir = os.path.join(project_dir, "greenlight", "models", "katzin_2021", "output")

# Location of greenhouse data from Katzin (2020)
data_dir = os.path.join(project_dir, "greenlight", "models", "katzin_2021", "input_data", "katzin_2020_original")

"""Load simulation results"""
climate_sim_hps = ao.make_output_df(os.path.join(output_dir, "katzin_2020_climate_hps.csv"))
climate_sim_led = ao.make_output_df(os.path.join(output_dir, "katzin_2020_climate_led.csv"))
energy_sim_hps = ao.make_output_df(os.path.join(output_dir, "katzin_2020_energy_hps.csv"))
energy_sim_led = ao.make_output_df(os.path.join(output_dir, "katzin_2020_energy_led.csv"))

# Read the old data files - only the first 288*112 rows - representing 112 days in 5-minute intervals
# The assumption is that the files have been placed in the right folder - see description in top of this file
greenhouse_data_hps = pd.read_csv(os.path.abspath(os.path.join(data_dir, "dataHPS.csv")), header=None).iloc[:32256, :]
greenhouse_data_led = pd.read_csv(os.path.abspath(os.path.join(data_dir, "dataLED.csv")), header=None).iloc[:32256, :]

# The columns in the old data files - see Readme of https://data.4tu.nl/datasets/78968e1b-eaea-4f37-89f9-2b98ba3ed865
columns = [
    "Time",
    "iGlob",
    "tOut",
    "rhOut",
    "wind",
    "tAir",
    "vpdAir",
    "uThScr",
    "uBlScr",
    "ventLee",
    "ventWind",
    "tPipe",
    "tGroPipe",
    "uLamp",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "uExtCo2",
    "co2InPpm",
]
greenhouse_data_hps.columns = columns
greenhouse_data_led.columns = columns

"""Generate Tables 3-4 from Katzin (2020)"""

table_3, greenhouse_data_hps, greenhouse_data_led = generate_table_3(
    greenhouse_data_hps, greenhouse_data_led, climate_sim_hps, climate_sim_led, energy_sim_hps, energy_sim_led
)


print(table_3)

table_4 = generate_table_4(climate_sim_hps, climate_sim_led)
print(table_4)

"""Generate Figures 5-7 from Katzin (2020)"""
generate_fig_5(
    greenhouse_data_hps, greenhouse_data_led, climate_sim_hps, climate_sim_led, energy_sim_hps, energy_sim_led
)
generate_fig_6(greenhouse_data_hps, greenhouse_data_led, climate_sim_hps, climate_sim_led)
generate_fig_7(climate_sim_hps, climate_sim_led)
