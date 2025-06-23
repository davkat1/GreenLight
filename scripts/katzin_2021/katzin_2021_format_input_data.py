"""
GreenLight/scripts/katzin_2021/katzin_2021_format_input_data.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Create formatted weather input files for running simulations as in Katzin (2021), Chapter 4:
    See Katzin, David (2021). Energy Saving by LED Lighting in Greenhouses : A Process-Based Modelling Approach.
    PhD thesis, Wageningen University. https://doi.org/10.18174/544434

In order to create these files, first data weather files must be downloaded from the EnergyPlus website and placed in
the expected location:

1. Use the EnergyPlus website (https://energyplus.net/weather) to download weather files (see below) in EPW format
2. Download the EnergyPlus software from https://energyplus.net/downloads and install it
3. Use EnergyPlus' Weather Conversions and Statistics program to convert the EPW file to CSV
4. Place the generated CSV files in models/katzin_2021/input_data/energyPlus_original/

In order to run the Katzin (2021a) simulations, the following locations must be downloaded:
    Amsterdam, The Netherlands (IWEC)
    Anchorage-Merrill Field, Alaska, USA (TMY3)
    Arkhangelsk, Russia (IWEC)
    Beijing-Beijing, China (CSWD)
    Calgary, Canada (CWEC)
    Chengdu, China (CSWD)
    Kiruna, Sweden (IWEC)
    Moscow, Russia (IWEC)
    Samara, Russia (IWEC)
    Shanghai, China (CSWD)
    St Petersburg, Russia (IWEC)
    Tokyo, Japan (IWEC)
    Urumqi, China (CSWD)
    Venice, Italy (IWEC)
    Windsor, Canada (CWEC)

It is expected that the EnergyPlus weather files keep their default file names (e.g., NLD_Amsterdam.062400_IWECEPW.csv)
"""

import datetime as dt
import os
import sys

import greenlight

"""Set up directories"""
if "__file__" in locals():  # Running this from script
    project_dir = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../.."))
else:
    project_dir = os.getcwd()  # Most likely the active directory is the project directory
sys.path.append(project_dir)

# Assuming that the original EnergyPlus files are in greenlight/models/katzin_2021/input_data/energyPlus_original
# See docstring above on how to obtain these files
input_dir = os.path.abspath(os.path.join(project_dir, "models", "katzin_2021", "input_data", "energyPlus_original"))
output_dir = os.path.abspath(os.path.join(project_dir, "models", "katzin_2021", "input_data", "energyPlus_formatted"))
if not os.path.exists(output_dir):
    os.makedirs(output_dir)


"""Create weather files formatted according to the Katzin 2021 format"""
# Dictionary for converting the EnergyPlus filenames to those used in Katzin 2021a
location_dict = {
    "CAN_AB": "cal",
    "CAN_ON": "win",
    "CHN_Be": "bei",
    "CHN_Sh": "sha",
    "CHN_Si": "che",
    "CHN_Xi": "uru",
    "ITA_Ve": "ven",
    "JPN_To": "tok",
    "NLD_Am": "ams",
    "RUS_Ar": "ark",
    "RUS_Mo": "mos",
    "RUS_Sai": "stp",
    "RUS_Sam": "sam",
    "SWE_Ki": "kir",
    "USA_AK": "anc",
}

# Generate the files
for file_name in os.listdir(input_dir):
    for key in location_dict.keys():
        if file_name.startswith(key):
            greenlight.convert_energy_plus(
                energy_plus_csv_path=os.path.join(input_dir, file_name),
                output_file_path=os.path.join(output_dir, f"weather_{location_dict[key]}_katzin_2021.csv"),
                t_out_start=dt.datetime(year=2020, month=9, day=27),
                t_out_end=dt.datetime(year=2020, month=9, day=27) + dt.timedelta(days=350),
                co2_out_ppm=410,  # See https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/inputs/energyPlus/energyPlusCsv2Mat.m, line 38
                output_format="katzin2021",
            )
