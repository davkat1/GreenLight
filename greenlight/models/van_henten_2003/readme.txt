GreenLight/greenlight/models/van_henten_2003/
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

About: using EnergyPlus weather data for the Van Henten (2003) model

EnergyPlus weather data for the Van Henten (2003) model can be acquired in the following way:
	1. Use the EnergyPlus website (https://energyplus.net/weather) to download any weather location of your choosing, download the EPW format
	2. Download the EnergyPlus software from https://energyplus.net/downloads and install it
	3. Use EnergyPlus' Weather Conversions and Statistics program to convert the EPW file to CSV
	4. Use greenlight.convert_energy_plus to convert from EnergyPlus CSV format to the format needed by the Van Henten (2003) model
		Example:
		>>> import os
		>>> import greenlight
		>>> os.chdir(<location of energyPlus CSV>)
		>>> greenlight.convert_energy_plus("NLD_Amsterdam.062400_IWECEPW.csv", "energyPlus_ams_evh2003.csv", output_format="evh2003")

David Katzin, Wageningen University & Research, May 2025
