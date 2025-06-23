"""
GreenLight/scripts/katzin_2020/katzin_2020_run_sims.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Run the simulations as in Katzin (2020, also published as Katzin 2021 Chapter 3) greenhouse model simulations,
used to compare model outputs with real data recorded in a greenhouse.

In order to run the simulations, the input data must first be acquired. For this, follow the instructions in
katzin_2020_format_input_data.py.

References:
    Katzin, D., van Mourik, S., Kempkes, F., & van Henten, E. J. (2020). GreenLight – An open source model for
        greenhouses with supplemental lighting: Evaluation of heat requirements under LED and HPS lamps.
        Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010
    Katzin, D. (2021). Energy Saving by LED Lighting in Greenhouses : A Process-Based Modelling Approach.
        PhD thesis, Wageningen University. https://doi.org/10.18174/544434
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

base_path = os.path.join(project_dir, "models")
output_dir = os.path.join("katzin_2021", "output")
model_def = os.path.join("katzin_2021", "definition", "main_katzin_2020.json")

"""Run simulations"""
# LED - climate
output_file_name = "katzin_2020_climate_led.csv"

# Add pipe temperature data as input to the simulation
modifications = ["katzin_2021/input_data/katzin_2020_formatted/t_pipe_Bleiswijk_2010_led.csv"]

input_prompt = [model_def, modifications]

led_climate = GreenLight(
    base_path=base_path, input_prompt=input_prompt, output_path=os.path.join(output_dir, output_file_name)
)
led_climate.run()

# HPS - climate
output_file_name = "katzin_2020_climate_hps.csv"

modifications = [
    # Change lamp parameters to HPS lamps
    "katzin_2021/definition/lamp_hps_katzin_2020.json",
    # Override climate data from LED compartment with data from HPS compartment
    "katzin_2021/input_data/katzin_2020_formatted/greenhouse_data_Bleiswijk_2010_hps.csv",
    # Add pipe temperature data as input to the simulation
    "katzin_2021/input_data/katzin_2020_formatted/t_pipe_Bleiswijk_2010_hps.csv",
]
input_prompt = [model_def, modifications]

hps_climate = GreenLight(
    base_path=base_path, input_prompt=input_prompt, output_path=os.path.join(output_dir, output_file_name)
)
hps_climate.run()

# LED - energy
output_file_name = "katzin_2020_energy_led.csv"

modifications = [
    # Add heating setpoint data as input to the simulation
    "katzin_2021/input_data/katzin_2020_formatted/heating_setpoint_Bleiswijk_2010_led.csv",
    # Following GreenLight1.0
    # (see https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/runScenarios/evaluateEnergyUseLed.m),
    # increase the setpoint by 0.5 so the desired setpoint is actually achieved
    {
        "uBoil": {"definition": "proportionalControl(tAir, heatSetPoint+0.5, tHeatBand, 0, 1)"},
        "uBoilGro": {"definition": "proportionalControl(tAir, heatSetPoint+0.5, tHeatBand, 0, 1)"},
    },
]

input_prompt = [model_def, modifications]

led_energy = GreenLight(
    base_path=base_path, input_prompt=input_prompt, output_path=os.path.join(output_dir, output_file_name)
)
led_energy.run()

# HPS - energy
output_file_name = "katzin_2020_energy_hps.csv"

modifications = [
    # Change lamp parameters to HPS lamps
    "katzin_2021/definition/lamp_hps_katzin_2020.json",
    # Override climate data from LED compartment with data from HPS compartment
    "katzin_2021/input_data/katzin_2020_formatted/greenhouse_data_Bleiswijk_2010_hps.csv",
    # Add heating setpoint data as input to the simulation
    "katzin_2021/input_data/katzin_2020_formatted/heating_setpoint_Bleiswijk_2010_hps.csv",
    # Following GreenLight1.0
    # (see https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/runScenarios/evaluateEnergyUseHps.m),
    # increase the setpoint by 0.5 so the desired setpoint is actually achieved
    {
        "uBoil": {"definition": "proportionalControl(tAir, heatSetPoint+0.5, tHeatBand, 0, 1)"},
        "uBoilGro": {"definition": "proportionalControl(tAir, heatSetPoint+0.5, tHeatBand, 0, 1)"},
    },
]

input_prompt = [model_def, modifications]

hps_energy = GreenLight(
    base_path=base_path, input_prompt=input_prompt, output_path=os.path.join(output_dir, output_file_name)
)
hps_energy.run()
