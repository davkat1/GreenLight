GreenLight/greenlight/models/katzin_2021/
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

About: getting and using input data for the models defined in this folder.

The Katzin (2021) and Vanthoor (2011) models can use EnergyPlus data, which can be acquired in the following way:
	1. Use the EnergyPlus website (https://energyplus.net/weather) to download any weather location of your choosing, download the EPW format
	2. Download the EnergyPlus software from https://energyplus.net/downloads and install it
	3. Use EnergyPlus' Weather Conversions and Statistics program to convert the EPW file to CSV
	4. Use greenlight.convert_energy_plus to convert from EnergyPlus CSV format to the required format:
		a. For use of the data for a combined greenhouse-crop model, the format of katzin2021 works for Katzin 2021 and Vanthoor 2011. Follow the following example:
            >>> import os
            >>> import greenlight
            >>> os.chdir(<location of energyPlus CSV>)
            >>> greenlight.convert_energy_plus("NLD_Amsterdam.062400_IWECEPW.csv", "energyPlus_ams_katzin_2021.csv")
            This will generate a weather file that can be used with Katzin 2021, and Vanthoor 2011, starting on January 1

	    b. For use of the data for a standalone crop model, follow the following example:
            >>> import os
            >>> import datetime as dt
            >>> import greenlight
            >>> os.chdir(<location of energyPlus CSV>)
            >>> greenlight.convert_energy_plus("NLD_Amsterdam.062400_IWECEPW.csv", "energyPlus_ams_vanthoor_crop.csv",
                t_out_start=dt.datetime(year=2021, month=5, day=15),
                t_out_end=dt.datetime(year=2021, month=10, day=1),
                output_format="vanthoor_crop")
            This will generate a weather file that can be used with the standalone tomato crop model (no greenhouse) of Vanthoor 2011.
            Note: the "vanthoor_crop" generates climate data which is representative of an outdoor crop. Therefore a summer period was chosen where outdoor tomato cultivation is possible.
    5. Place the generated file(s) in input_data\energyPlus_formatted

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

After converting the EPW files to CSV, place them in input_data/energyPlus_original.
Then, run scripts/katzin_2021/katzin_2021_format_input_data.py to generate input files as in Katzin (2021a), i.e., Katzin (2021), Chapter 4.
Now scripts/katzin_2021/katzin_2021_run_sims.py can be run

The Katzin (2020) model is meant to reproduce the results of Katzin (2020). This model definition can be run by doing the following
    1. Download "Simulation data.zip" from https://data.4tu.nl/datasets/78968e1b-eaea-4f37-89f9-2b98ba3ed865
    2. Unzip "Simulation data.zip", copy the contents of "CSV output" to input_data/katzin_2020_original
    3. Run scripts/katzin_2020/katzin_2020_format_input_data.py
    4. Now, scripts/katzin_2020/katzin_2020_run_sims.py can be run

David Katzin, Wageningen University & Research, May 2025
