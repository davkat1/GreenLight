"""
GreenLight/scripts/katzin_2021/katzin_2021_run_sims.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Run the simulations as in Katzin (2021a, also published as Katzin 2021 Chapter 4) greenhouse model simulations,
used to estimate energy use of greenhouses with HPS and LED lamps.

In order to run the simulations, the input weather data must first be acquired. For this, follow the instructions in
katzin_2021_format_input_data.py. Place the generated CSV files in input_data/energyPlus_formatted.

References:
    Katzin, D. (2021). Energy Saving by LED Lighting in Greenhouses : A Process-Based Modelling Approach.
        PhD thesis, Wageningen University. https://doi.org/10.18174/544434
    Katzin, Marcelis, Van Mourik (2021a). Energy Savings in Greenhouses by Transition from High-Pressure Sodium
        to LED Lighting. Applied Energy 281:116019. https://doi.org/10.1016/j.apenergy.2020.116019
"""

import os
import sys

from greenlight import GreenLight

"""Set up directories"""
if "__file__" in locals():  # Running this from script
    project_dir = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../.."))
else:
    project_dir = os.getcwd()  # Most likely the active directory is the project directory
sys.path.append(project_dir)

base_path = os.path.join(project_dir, "greenlight", "models")
input_dir = os.path.join("katzin_2021", "input_data", "energyPlus_formatted")
output_dir = os.path.join("katzin_2021", "output")
model_def = os.path.join("katzin_2021", "definition", "main_katzin_2021.json")

"""Get list of location names"""
locations = []
for file_name in os.listdir(os.path.join(base_path, input_dir)):
    if file_name.startswith("weather_"):
        locations.append(file_name[8:11])  # Assuming file names start with "weather_<3_char_location_code>"

"""Numbers of days to simulate"""
n_days = 350
options = {"options": {"t_end": str(n_days * 24 * 3600), "solver": "BDF"}}

"""Run simulations"""
for loc in locations:
    weather_file = os.path.join(input_dir, "weather_" + loc + "_katzin_2021_from_sep_27_000000.csv")

    # LED
    output_file_name = "katzin_2021_" + loc + "_led.csv"
    if output_file_name not in os.listdir(os.path.join(base_path, output_dir)):
        input_prompt = [model_def, weather_file, options]
        print(f"\nLoading model for location {loc}, LED lamps")
        led = GreenLight(
            base_path=base_path, input_prompt=input_prompt, output_path=os.path.join(output_dir, output_file_name)
        )
        led.run()

    # HPS
    output_file_name = "katzin_2021_" + loc + "_hps.csv"
    if output_file_name not in os.listdir(os.path.join(base_path, output_dir)):
        input_prompt = [
            model_def,
            weather_file,
            options,
            os.path.join("katzin_2021", "definition", "lamp_hps_katzin_2021.json"),
        ]
        print(f"\nLoading model for location {loc}, HPS lamps")
        hps = GreenLight(
            base_path=base_path, input_prompt=input_prompt, output_path=os.path.join(output_dir, output_file_name)
        )
        hps.run()
