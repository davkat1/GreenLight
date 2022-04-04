GreenLight - A model for greenhouses with supplemental lighting
=========================================

A model for simulating the indoor climate and energy use of greenhouses with supplemental lighting. 

## Maintainers
* David Katzin, `david.katzin@wur.nl`, `david.katzin1@gmail.com`

## Cite as

David Katzin, Simon van Mourik, Frank Kempkes, and Eldert J. Van Henten. 2020. “GreenLight - An Open Source Model for Greenhouses with Supplemental Lighting: Evaluation of Heat Requirements under LED and HPS Lamps.” Biosystems Engineering 194: 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010

## Compatability
The code in this repository has been tested for compatibility with MATLAB 2015b and onwards. The [DyMoMa](https://github.com/davkat1/DyMoMa/) package is required in order to use this model. The current version uses [DyMoMa v1.0.1](https://github.com/davkat1/DyMoMa/releases/tag/v1.0.1).

## User's guide
A user's guide for GreenLight and DyMomMa is available in Chapter 7 (pages 235-280) of [David Katzin's PhD thesis](https://doi.org/10.18174/544434). Also see some examples and explanations in this readme, below.

## Use of the model in published studies

### Code and data used for Chapter 5 of [Katzin, 2021](https://doi.org/10.18174/544434)
Simulations for this study were performed by running "Code/runScenarios/heatByLightScript.m". The version of the code used was the one in [commit 78a2e8b of GreenLight](https://github.com/davkat1/GreenLight/commit/78a2e8b1dff91a127787eeb69b35d29c5b37e896) and [commit 33edf69 of DyMoMa](https://github.com/davkat1/DyMoMa/commit/33edf691ace81daf71cbf89ff75824d53abc2308). The resulting output is available on the associated dataset on the [4TU.ResearchData database](https://doi.org/10.4121/14575965.v1).

The figures using in the chapter were generated using the output files available on the [4TU.ResearchData database](https://doi.org/10.4121/14575965.v1) by running the scripts in "Code/postSimAnalysis/katzinThesisFigures/Chapter 5".

### Code and data used for [Katzin, Marcelis, Van Mourik](https://doi.org/10.1016/j.apenergy.2020.116019) (2021, Applied Energy)
The simulations described in this study were executed by running the file `Code\runScenarios\runWorldSimulations.m`. The version of the code used was the one in [commit 2d1f510 of GreenLight](https://github.com/davkat1/GreenLight/commit/2d1f510827b4e6460dac21c248617844304af194) and [commit 172a76e of DyMoMa](https://github.com/davkat1/DyMoMa/commit/172a76e22da1cdd6ed6a90e0e2632b8e83958859). The resulting output is available on the associated dataset on the [4TU.ResearchData database](https://doi.org/10.4121/13096403).

The figures used in the publication were generated from the files included in [this dataset](https://doi.org/10.4121/13096403). The version of the code used to generate the figures was the one in [commit f9c5ec3 of GreenLight](https://github.com/davkat1/GreenLight/commit/f9c5ec3ec61f8ef65616183621563e557429595a) and [commit f5e5ce3 of DyMoMa](https://github.com/davkat1/DyMoMa/commit/f5e5ce3285d864707c94d60ce33f3e15c5e080a5).
The following files were used for each figure:

- **Fig. 01:** Yearly cycle of global solar radiation vs outdoor air temperature in the 15 locations considered.
	- `Code\inputs\energyPlus\plotYearlyCycleTempRad.m`
- **Fig. 02:** Yearly means of solar radiation and outdoor air temperature in the 15 locations considered.
	- `Code\inputs\energyPlus\scatterYearAvgTempRad.m`		
- **Fig. 03:** Control of heating, ventilation and thermal screen in the reference setting.
	- Textual image generated using Microsoft Visio software
- **Fig. 04:** Response of a smoothed proportional controller to a process variable according to a sigmoid function.
	- `Code\serviceFunctions\plotExamplePropControl.m`
- **Fig. 05:** Potential fraction of energy saved assuming that the heat requirements remain equal.
	- `Code\serviceFunctions\plotLightSavingsNoHeat.m`
- **Fig. 06:** Heating and lighting demand of HPS and LED greenhouses in different locations, under the reference settings.
	- `Code\postSimAnalysis\barEnergyUseWorldWide.m`
- **Fig. 07:** Simulated savings in total energy input by transitioning from HPS to LEDs.
	- `Code\postSimAnalysis\scatterFracLightSavingsAnalysis.m`
- **Fig. 08:** Yearly incoming and outgoing energy fluxes for the HPS, LED, and LED temperatureAdjustment in Amsterdam.
	- `Code\postSimAnalysis\barEnergyFluxesYearWithHeatAdj.m`
- **Fig. 09:** Time course during the year for daily energy inputs and daily outdoor weather in Amsterdam.
	- `Code\postSimAnalysis\plotDailyEnergyFullYear.m`
- **Fig. 10:** Incoming and outgoing energy fluxes in Amsterdam on a representative winter and summer day.
	- `Code\postSimAnalysis\barEnergyFluxes.m`
- **Fig. 11:** Time course of a representative winter and summer day in Amsterdam. 
	- `Code\postSimAnalysis\plotWinterSummerDayTrajectory.m`

### Code used for [Katzin, Van Mourik, Kempkes, Van Henten](https://doi.org/10.1016/j.biosystemseng.2020.03.010) (2020, Biosystems Engineering)
The files `Code\runScenarios\evaluateClimateModelHps.m` and `Code\runScenarios\evaluateClimateModelLed.m` were used to evalute the climate model (**Table 3**, **Fig. 6**). 

The files `Code\runScenarios\evaluateEnergyUseHps.m` and `Code\runScenarios\evaluateEnergyUseLed.m` were used to evaluate the predicted energy use (**Table 3**, **Fig. 5**).

In order to replicate these figure, data recorded by Wageningen Greenhouse Horticulture was used. This data is under copyright and unfortunately could not be shared in this repository. More information about the data is available in:

- Dueck, T. A., Janse, J., Schapendonk, A. H. C. M., Kempkes, F., Eveleens, B., Scheffers, K., Pot, S., Trouwborst, G., Nederhoff, E., & Marcelis, L. (2010). [Lichtbenuttig van tomaat onder LED en SON-T belichting](https://library.wur.nl/WebQuery/wurpubs/401925).
- Dueck, T. A., Janse, J., Eveleens, B. A., Kempkes, F., & Marcelis, L. F. M. (2012). [Growth of tomatoes under hybrid LED and HPS lighting](https://doi.org/10.17660/ActaHortic.2012.952.42). Acta Horticulturae, 1(952), 335–342. 

The file `Code\postSimAnalysis\lampOutput.m` was used to analyze the energy outputs of the lamps (**Table 4**).

The version of the code used for this study is the one in [commit 8ba6eaa of GreenLight](https://github.com/davkat1/GreenLight/commit/8ba6eaad17c4cff4f3481e5f3ad87ad212140d6a) and [commit 0abbb7b of DyMoMa](https://github.com/davkat1/DyMoMa/commit/0abbb7b99db6e5922c4b61651e1a21403b4e1467).

## Using the model

Make sure you have all files in this repository, as well as those from the DyMoMa package, on your MATLAB path. 

### Example simulations

`runScenarios\exampleSimulation` shows how you may use a dataset of weather data (in this case, the Reference Year for Dutch Greenhouses), to run the model with default settings. The plot made here is of the lamp temperatures, but you may plot whatver model component you wish.

`runScenarios\exampleSimulation2` shows more uses of the model, now run with settings for a modern greenhouse, including plotting the outputs.

`runScenarios\exampleCropModel.m` gives a simple example of running only the crop component of the model.

### Scenario simulations as in [Katzin, Marcelis, Van Mourik](https://doi.org/10.1016/j.apenergy.2020.116019) (2021, Applied Energy)
- The file `Code\runScenarios\runWorldSimulations.m` provides an example of running the model in various climate settings and with various model parameters. A list of the model parameters is available in `Code\createGreenLightModel\setGlParams.m'.
- In order to analyze simulations output, the files available in the [associated dataset](https://doi.org/10.4121/13096403) can be used. This data can be explored further.

#### Example 1
In order to generate a figure as in Fig. 06, but with the "colder" setting instead of the "reference" setting, use `GreenLight\Code\postSimAnalysis\barEnergyUseWorldWide.m` but replace Line 15:

	outputFolder = strrep(currentFolder, '\GreenLight\Code\postSimAnalysis', ...
    '\GreenLight\Output\referenceSetting\');
	
with:

	outputFolder = strrep(currentFolder, '\GreenLight\Code\postSimAnalysis', ...
    '\GreenLight\Output\colder\');

#### Example 2
In order to generate a figure as in Fig. 11 for Beijing instead of Amsterdam, use file `GreenLight\Code\postSimAnalysis\plotWinterSummerDayTrajectory.m`, and replace lines 24-27:

	load([outputFolder 'ams_hps_referenceSetting.mat'],'gl');
	hps = gl;
	load([outputFolder 'ams_led_referenceSetting.mat'],'gl');
	led = gl;
	
with:

	load([outputFolder 'bei_hps_referenceSetting.mat'],'gl');
	hps = gl;
	load([outputFolder 'bei_led_referenceSetting.mat'],'gl');
	led = gl;
	
#### Example 3
In order to generate a figure as in Fig. 10 for different days in the growing season (e.g., December 1 and June 1), use file `GreenLight\Code\postSimAnalysis\barEnergyFluxes.m`. Modify lines 45-56:

	winterDay = 116;
	summerDay = 292;
	
To:

	winterDay = 65;
	summerDay = 248;

### Model evaluation as in [Katzin, Van Mourik, Kempkes, Van Henten 2020](https://doi.org/10.1016/j.biosystemseng.2020.03.010) (Biosystems Engineering)
- Examples of an evaluation of the climate model are given in `Code\runScenarios\evaluateClimateModelHps.m` and `Code\runScenarios\evaluateClimateModelLed.m`.
- Examples of an evaluation of energy use are given in `Code\runScenarios\evaluateEnergyUseHps.m` and `Code\runScenarios\evaluateEnergyUseLed.m`.

Unfortunately these files cannot be run without the data from the Bleiswijk 2010 trial, which is not included in this repository. However these examples can be used to run the model with other datasets. You can see in these examples how to compare the model simulations to the measured values, including measured climate variables and energy use.

## Files in this repository

- `readme.md` - This readme file
- `license.md` - The license for this repository (Apache 2.0)
- *Code*
	- `createGreenLightModel` - Files for creating an object of a greenhouse model with lights
	   - `createCropModel.m` - Create only the crop model component of a GreenLight model. See also `exampleCropModel` in `runScenarios`
	   - `createGreenLightModel.m` - Main function for creating a new GreenLight model object. See also `runGreenLight` in `runScenarios`
	   - `setBleiswijk2010HpsParams.m` - Set the lamp parameters according to the HPS compartment in Bleiswijk, The Netherlands, 2010. Used in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
	   - `setBleiswijk2010LedParams.m` - Set the lamp parameters according to the LED compartment in Bleiswijk, The Netherlands, 2010. Used in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
	   - `setDefaultLampParams.m` - Set lamp parameters according to modern specifications
	   - `setDepParams.m` - After the parameters have been set, reset the dependent parameters
	   - `setGlAux.m` - Set the auxiliary states 
	   - `setGlControlRules.m` - Set the control rules 
	   - `setGlControls.m` - Set the controls 
	   - `setGlInit.m` - Set the inital values for the states
	   - `setGlInput.m` - Set the inputs
	   - `setGlOdes.m` - Set the ODEs
	   - `setGlParams.m` - Set the parameters according to the Vanthoor model
	   - `setGlStates.m` - Set the states
	   - `setGlTime.m` - Set the timespan
	   - `setParams4haWorldComparison.m` - Set the parameters according to a modern 4 ha greenhouse. Used in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
	   - `setParamsBleiswijk2010.m` - Set the parameters according to a data set from Bleiswijk, The Netherlands, 2010. Used in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
	- *inputs* - Files for defining the outdoor climate inputs
	   - `cloudCoverRotterdam2009-2012` - Cloud cover data in Rotterdam for the years 2009-2012
	   - `Reference year SEL2000` - Weather data from a Reference Year for Dutch Greenhouses
	   - `energyPlus` - Data from the EnergyPlus database. Used in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
			- `data` - The actual data files
			- `cutEnergyPlusData.m` - Cut data from EnergyPlus to fit a desired season length
			- `energyPlusCsv2Mat.m` - Convert EnergyPlus data from CSV to MAT
			- `plotYearlyCycleTempRad.m` - Make a plot of yearly cycle of temperature and radiation for all data files. Used to create Figure 1 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
			- `scatterYearAvgTempRad.m` - Make a scatter plot of yearly average temperature and radiation for all data files. Used to create Figure 2 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
			- `readme.txt` - More information on the EnergyPlus data
	   - `dayLightSum.m` - Add a column of daily radiation sum to the input file
	   - `loadGreenhouseData.m` - Load data from Bleiswijk 2010 datasets (tha data not included in this repository)
	   - `loadSelYearHiRes.m` - Load weather data from Reference Year for Dutch Greenhouses
	   - `skyTempMonteith.m` - Calculate sky temperature according to a given air temperature and cloud cover
	   - `skyTempRdam.m` - Calculate sky temperature in Rotterdam according to `skyTempMonteith` and the data in `cloudCoverRotterdam2009-2012`
	   - `soilTempNl.m` - Calculate soil temperature for Dutch conditions
	- *postSimAnalysis* - Methods for analyzing and viewing the simulation after it's done
		- `barEnergyFluxes.m` - Create a bar chart of the energy fluxes. Used to create Figure 10 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
		- `barEnergyFluxesYearWithHeatAdj.m` - Create a bar chart of the energy fluxes, including a simulation with LED heat adjustment. Used to create Figure 8 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
		- `barEnergyUseWorldWide.m` - Create a bar chart of energy use of simulations around the world. Used to create Figure 6 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
		- `energyAnalysis.m` - Calculate the values of the simultaed energy balance
		- `energyCompare.m` - Compare the energy fluxes of two simulations
		- `groPipeEnergy.m` - Calculates how much energy came from the grow pipes
		- `lampOutput.m` - Prints out how the lamp output was broken down between PAR, NIR, FIR, convection, and cooling. Used to create Table 4 in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
		- `pipeEnergy.m` - Calculates how much energy came from the pipe rails	   
		- `pipeT2EnergyIn.m` - Calculates how much energy came from the pipe, based on pipe temperature and the table by Verveer
		- `plotDailyEnergyFullYear.m` - Plot the trajectory of daily energy use throughout the year. Used to create Figure 9 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
		- `plotTemps.m` - Plot the temperatures of the various states in the model
		- `plotWinterSummerDayTrajectory.m` - Plot the trajectories of a chosen day in winter and summer. Used to create Figure 11 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
		- `scatterFracLightSavingsAnalysis.m` - Analyze the energy saving by transition to LEDs, as a function of fraction of energy input that goes to lighting. Used to create Figure 7 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)		
		- `verveer.mat` - Table relating pipe temperature and diameter to energy use
		- `verveerReadme.txt` - Explanation regarding the table in `vermeer.mat`
	- *runScenarios* - Scenarios considered in the current study
		- `evaluateClimateModelHps.m` - File used for comparing indoor model simulations with measured data under HPS (data not included in this repo). Used to create Table 3 and Figure 6 in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
		- `evaluateClimateModelLed.m` - File used for comparing indoor model simulations with measured data under LED (data not included in this repo). Used to create Table 3 and Figure 6 in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
		- `evaluateEnergyUseHps.m` - File used for comparing model simulations of energy use with measured data under HPS (data not included in this repo). Used to create Table 3 and Figure 5 in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
		- `evaluateEnergyUseLed.m` - File used for comparing model simulations of energy use with measured data under LED (data not included in this repo). Used to create Table 3 and Figure 5 in [Katzin et al (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010)
		- `exampleCropModel.m` - Example of using only the crop model component of GreenLight
		- `exampleSimulation.m` - Example of a simulation with different lamp settings, with data from Reference Year for Dutch Greenhouses
		- `exampleSimulation2.m` - Example of a simulation of a modern greenhouse
		- `runGreenLight.m` - Run the GreenLight model for a modern greenhouse
		- `runWorldSimulations.m` - Run the model in various settings and climates. The main code used to generate the data in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)		
	- *serviceFunctions* - General use functions 
		- `co2dens2ppm.m` - Convert from CO2 density to ppm
		- `co2ppm2dens.m` - Convert from CO2 in ppm to density
		- `rh2vaporDens.m` - Convert from relative humidity to vapor density
		- `unplot.m` - Remove the last plotted line
		- `vaporDens2pres.m` - Convert from vapor density to vapor pressure
		- `vp2Dens.m` - Convert from vapor pressure to vapor density
		- `vp2dewPt.m` - Convert from vapor pressure to dew point
		- `plotExamplePropControl.m` - Plot an example of a smoothed propotional controller. Used to create Figure 4 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)
		- `plotLightSavingsNoHeat.m` - Plot expected energy savings on lighting as a function of lamp use and efficiency. Used to create Figure 5 in [Katzin et al (2021)](https://doi.org/10.1016/j.apenergy.2020.116019)