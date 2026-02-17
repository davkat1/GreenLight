GreenLight/greenlight/models/katzin_2021/input_data/test_data/
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Weather data from Bleiswijk, The Netherlands. From 20/10/2009 at 00:00, until 07/02/2010 at 23:55.
Formatted for use as an input to the Katzin 2021 model.

The data is from:
Katzin, D., Kempkes, F., van Mourik, S., van Henten, E., Dieleman, A., Dueck, T., Schapendonk, A., Scheffers, K., Pot, S., & Trouwborst, G. (2025). Data from: ‘GreenLight - An open source model for greenhouses with supplemental lighting: Evaluation of heat requirements under LED and HPS lamps’ (Version 2) [Csv, xlsx, mat]. 4TU.ResearchData. https://doi.org/10.4121/78968E1B-EAEA-4F37-89F9-2B98BA3ED865.V2

Specifically, the file:
Simulation data/CSV output/climateModel_hps_manuscriptParams.csv
was used.

The file was modified in the following ways:
	- The original dataset contained data from 19/10/2009 at 15:15, until 08/02/2010 at 15:10. Here, in order to have full days, data from 20/10/2009 at 00:00 until 07/02/2010 at 23:55 is given.
	- The Time column was modified to relative times in seconds - starting from 0, in 300 seconds increments
	- dayRadSum was calculated by taking iGlob values during that calendar day and multiplying the sum by 300e-6
		(300 because the data is in 300 s intervals, 1e-6 to convert from J to MJ)
	- isDay was calculated as 1 if iGlob>20, 0 otherwise
	- isDaySmooth was set equal to isDay
	- hElevation was set to -5, see https://www.rijkswaterstaat.nl/zakelijk/open-data/actueel-hoogtebestand-nederland

This file created by David Katzin, Wageningen University & Research, September 2025
