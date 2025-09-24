"""
GreenLight/scripts/katzin_2020/katzin_2020_format_input_data.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Format data from old version of GreenLight (GreenLight1.0) to a format that can be used by models/katzin_2021

In order to run this file, first the old data files must be acquired from:
    https://data.4tu.nl/datasets/78968e1b-eaea-4f37-89f9-2b98ba3ed865
    Download the file "Simulation data.zip", unzip it, and copy the contents of the folder "CSV output" to:
    models/katzin_2021/input_data/katzin_2020_original

The formatted files will be saved to:
    models/katzin_2021/input_data/katzin_2020_formatted

The following files will be generated:
    greenhouse_data_Bleiswijk_2010_hps.csv - greenhouse data from the HPS compartment
    greenhouse_data_Bleiswijk_2010_led.csv - greenhouse data from the LED compartment
    heating_setpoint_Bleiswijk_2010_hps.csv - heating setpoint data from the HPS compartment
    heating_setpoint_Bleiswijk_2010_led.csv - heating setpoint data from the LED compartment
    t_pipe_Bleiswijk_2010_hps.csv - pipe temperature data from the HPS compartment
    t_pipe_Bleiswijk_2010_led.csv - pipe temperature data from the LED compartment
"""

import os
import sys

import numpy as np
import pandas as pd

"""Set up directories"""
if "__file__" in locals():  # Running this from script
    project_dir = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../.."))
else:
    project_dir = os.getcwd()  # Most likely the active directory is the project directory
sys.path.append(project_dir)

# Assuming that the original data files are in greenlight/greenlight/models/katzin_2021/input_data/katzin_2020_original
# See docstring above on how to obtain these files
input_dir = os.path.abspath(
    os.path.join(project_dir, "greenlight", "models", "katzin_2021", "input_data", "katzin_2020_original")
)
output_dir = os.path.abspath(
    os.path.join(project_dir, "greenlight", "models", "katzin_2021", "input_data", "katzin_2020_formatted")
)
if not os.path.exists(output_dir):
    os.makedirs(output_dir)


def create_greenhouse_data(original_data_path: str, lamp_type: str, output_folder: str) -> None:
    """
    Format data from the Katzin 2020 publication to a format used by the current version of GreenLight.
    In order to use this function, first get the old simulation data from
    https://data.4tu.nl/datasets/78968e1b-eaea-4f37-89f9-2b98ba3ed865
    unzip "Simulation data.zip" and extract the contents of subfolder "CSV output" to
    models/katzin_2021/input_data/katzin_2020_original/

    The generated files will be placed in output_folder. The following files will be generated:
        greenhouse_data_Bleiswijk_2010_hps.csv - greenhouse data from the HPS compartment
        greenhouse_data_Bleiswijk_2010_led.csv - greenhouse data from the LED compartment
        heating_setpoint_Bleiswijk_2010_hps.csv - heating setpoint data from the HPS compartment
        heating_setpoint_Bleiswijk_2010_led.csv - heating setpoint data from the LED compartment
        t_pipe_Bleiswijk_2010_hps.csv - pipe temperature data from the HPS compartment
        t_pipe_Bleiswijk_2010_led.csv - pipe temperature data from the LED compartment

    :param original_data_path: Location of local folder containing the contents of "CSV output", as described above
    :param lamp_type: Either "hps" or "led". Influences which dataset is used from the old data.
    :param output_folder: Location where formatted data will be placed
    :return: None
    """

    # Get old simulation data, acquired from:
    # https://data.4tu.nl/datasets/78968e1b-eaea-4f37-89f9-2b98ba3ed865
    # In "Simulation data.zip", subfolder "CSV output"
    if lamp_type == "hps":
        climate_file = "climateModel_hps_manuscriptParams.csv"  # Climate model evaluation results
        energy_file = "energyUse_hps__manuscriptParams_1-1.csv"  # Energy use model evaluation results
    elif lamp_type == "led":
        climate_file = "climateModel_led_manuscriptParams.csv"  # Climate model evaluation results
        energy_file = "energyUse_led__manuscriptParams_1-1.csv"  # Energy use model evaluation results
    else:
        raise ValueError("Error in lamp_type: use 'hps' or 'led'")

    # Read the old data files
    climate_df = pd.read_csv(os.path.abspath(os.path.join(original_data_path, climate_file)))
    energy_df = pd.read_csv(os.path.abspath(os.path.join(original_data_path, energy_file)))

    # Variables of the general greenhouse data file
    input_column_names = [
        "Outdoor temperature (°C)",
        "Outdoor vapor pressure (Pa)",
        "Outdoor CO2 concentration (mg m^{-3})",
        "Outdoor wind speed (m s^{-1})",
        "Apparent sky temperature (°C)",
        "Temperature of external soil layer (°C)",
        "Global solar radiation (W m^{-2})",
        "Shading screen position (0-1)",
        "Thermal screen position (0-1)",
        "Blackout screen position (0-1)",
        "Roof ventilation position (0-1)",
        "Lamp status (0-1)",
        "Interlamp status (0-1)",
        "CO2 injection valve position (0-1)",
    ]
    var_names = [
        "tOut",
        "vpOut",
        "co2Out",
        "wind",
        "tSky",
        "tSoOut",
        "iGlob",
        "uShScr",
        "uThScr",
        "uBlScr",
        "uRoof",
        "uLamp",
        "uIntLamp",
        "uExtCo2",
    ]
    var_units = ["°C", "Pa", "mg m**-3", "m s**-1", "°C", "°C", "W m**-2", "-", "-", "-", "-", "-", "-", "-"]
    var_descs = [
        "Outdoor temperature",
        "Outdoor vapor pressure",
        "Outdoor CO2 concentration",
        "Outdoor wind speed",
        "Apparent sky temperature",
        "Temperature of external soil layer",
        "Global solar radiation",
        "Shading screen position",
        "Thermal screen position",
        "Blackout screen position",
        "Roof ventilation position",
        "Lamp status",
        "Interlamp status",
        "CO2 injection valve position",
    ]

    # Output for the general greenhouse data file
    gh_data_df = pd.DataFrame()
    units_df = pd.DataFrame()
    descs_df = pd.DataFrame()

    # Set Time to 300 second intervals
    var = "Time"
    gh_data_df[var] = np.arange(0, climate_df.shape[0] * 300, step=300)
    units_df.loc[0, var] = "s"
    descs_df.loc[0, var] = "Time since beginning of data"

    # Organize data, unit, and description per variable for the general greenhouse data file
    for col, var, unit, desc in zip(input_column_names, var_names, var_units, var_descs):
        gh_data_df[var] = climate_df[col]
        units_df.loc[0, var] = unit
        descs_df.loc[0, var] = desc

    # Save general greenhouse data file
    pd.concat([descs_df, units_df, gh_data_df]).to_csv(
        os.path.abspath(os.path.join(output_folder, "greenhouse_data_Bleiswijk_2010_" + lamp_type + ".csv")),
        encoding="utf-8-sig",
        index=False,
    )

    # Output for the heating setpoint and pipe temperature files
    heat_setpoint_df = pd.DataFrame()
    t_pipe_df = pd.DataFrame()

    heat_setpoint_df["Time"] = gh_data_df["Time"]
    t_pipe_df["Time"] = gh_data_df["Time"]

    # Heating setpoint comes from the energy use simulation file
    # This is equal to the recorded temperature in the real greenhouse
    heat_setpoint_df["heatSetPoint"] = energy_df["Heating setpoint (°C)"]

    # Define units and descriptions
    units_df = pd.DataFrame()
    units_df.loc[0, "Time"] = "s"
    units_df.loc[0, "heatSetPoint"] = "°C"

    descs_df = pd.DataFrame()
    descs_df.loc[0, "Time"] = "Time since beginning of data"
    descs_df.loc[0, "heatSetPoint"] = "Heating setpoint"

    # Save heating setpoint file
    pd.concat([descs_df, units_df, heat_setpoint_df]).to_csv(
        os.path.abspath(os.path.join(output_folder, "heating_setpoint_Bleiswijk_2010_" + lamp_type + ".csv")),
        encoding="utf-8-sig",
        index=False,
    )

    # Pipe temperatures come from the climate simulation file
    # These are equal to the recorded pipe temperatures in the real greenhouse
    t_pipe_df["tPipe"] = climate_df["Pipe rail temperature (°C)"]
    t_pipe_df["tGroPipe"] = climate_df["Grow pipe temperature (°C)"]

    # Define units and descriptions
    units_df = pd.DataFrame()
    units_df.loc[0, "Time"] = "s"
    units_df.loc[0, "tPipe"] = "°C"
    units_df.loc[0, "tGroPipe"] = "°C"

    descs_df = pd.DataFrame()
    descs_df.loc[0, "Time"] = "Time since beginning of data"
    descs_df.loc[0, "tPipe"] = "Pipe rail temperature"
    descs_df.loc[0, "tGroPipe"] = "Grow pipe temperature"

    # Save heating setpoint file
    pd.concat([descs_df, units_df, t_pipe_df]).to_csv(
        os.path.abspath(os.path.join(output_folder, "t_pipe_Bleiswijk_2010_" + lamp_type + ".csv")),
        encoding="utf-8-sig",
        index=False,
    )


# Create the greenhouse data files
create_greenhouse_data(input_dir, "hps", output_dir)
create_greenhouse_data(input_dir, "led", output_dir)
