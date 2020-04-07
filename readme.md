GreenLight - A model for greenhouses with supplemental lighting
=========================================

A model for simulating the indoor climate and energy use of greenhouses with supplemental lighting. 

## Maintainers
* David Katzin, `david.katzin@wur.nl`, `david.katzin1@gmail.com`

## Cite as

Katzin, David, Simon van Mourik, Frank Kempkes, and Eldert J. Van Henten. 2020. “GreenLight - An Open Source Model for Greenhouses with Supplemental Lighting: Evaluation of Heat Requirements under LED and HPS Lamps.” Biosystems Engineering 194: 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010.

## Compatability
The code in this repository has been tested for compatibility with MATLAB 2015b and onwards. The [DyMoMa](https://github.com/davkat1/DyMoMa/) package is required in order to use this model. The current version uses [DyMoMa v1.0.0](https://github.com/davkat1/DyMoMa/releases/tag/v1.0.0).

## In this repository

- `readme.md` - This readme file
- `license.md` - The license for this repository (Apache 2.0)
- *Code*
	- `createGreenLightModel` - Files for creating an object of a greenhouse model with lights
	   - `createGreenLightModel.m` - Main function for creating a new GreenLight model object
	   - `setGlParams.m` - Set the parameters according to the Vanthoor model
	   - `setGlInput.m` - Set the inputs
	   - `setGlTime.m` - Set the timespan
	   - `setGlControls.m` - Set the controls 
	   - `setGlStates.m` - Set the states
	   - `setGlAux.m` - Set the auxiliary states 
	   - `setGlControlRules.m` - Set the control rules 
	   - `setGlOdes.m` - Set the ODEs
	   - `setGlInit.m` - Set the inital values for the states
	   - `setParamsBleiswijk2010.m` - Set the parameters according to a data set from Bleiswijk, The Netherlands, 2010
	   - `setHpsParams.m` - Set the lamp parameters according to the HPS compartment in Bleiswijk, The Netherlands, 2010
	   - `setLedParams.m` - Set the lamp parameters according to the LED compartment in Bleiswijk, The Netherlands, 2010
	   - `setDepParams.m` - After the parameters have been set, reset the dependent parameters
	- *inputs* - Files for defining the outdoor climate inputs
	   - `cloudCoverRotterdam2009-2012` - Cloud cover data in Rotterdam for the years 2009-2012
	   - `Reference year SEL2000` - Weather data from a Reference Year for Dutch Greenhouses
	   - `loadGreenhouseData.m` - Load data from available greenhouse datasets (tha data not included in this repository)
	   - `loadSelYearHiRes.m` - Load weather data from Reference Year for Dutch Greenhouses
	   - `skyTempMonteith.m` - Calculate sky temperature according to a given air temperature and cloud cover
	   - `skyTempRdam.m` - Calculate sky temperature in Rotterdam according to `skyTempMonteith` and the data in `cloudCoverRotterdam2009-2012`
	   - `soilTempNl.m` - Calculate soil temperature for Dutch conditions
	- *postSimAnalysis* - Methods for analyzing and viewing the simulation after it's done
	   - `plotTemps.m` - Plot the temperatures of the various states in the model
	   - `pipeT2EnergyIn.m` - Calculates how much energy came from the pipe, based on pipe temperature and the table by Verveer
	   - `groPipeEnergy.m` - Calculates how much energy came from the grow pipes
	   - `pipeEnergy.m` - Calculates how much energy came from the pipe rails	   
	   - `energyAnalysis.m` - Prints out the values of the simultaed energy balance
	   - `lampOutput.m` - Prints out how the lamp output was broken down between PAR, NIR, FIR, convection, and cooling
	   - `verveer.mat` - Table relating pipe temperature and diameter to energy use
	   - `verveerReadme.txt` - Explanation regarding the table in `vermeer.mat`
	- *runScenarios* - Scenarios considered in the current study
		- `exampleSimulation.m` - Example of a simulation with different lamp settings, with data from Reference Year for Dutch Greenhouses
		- `evaluateClimateModelHps.m` - File used for comparing indoor model simulations with measured data under HPS (data not included in this repo)
		- `evaluateClimateModelLed.m` - File used for comparing indoor model simulations with measured data under LED (data not included in this repo)
		- `evaluateEnergyUseHps.m` - File used for comparing model simulations of energy use with measured data under HPS (data not included in this repo)
		- `evaluateEnergyUseLed.m` - File used for comparing model simulations of energy use with measured data under LED (data not included in this repo)
		
## Using the model

Make sure you have all files in this repository, as well as those from the DyMoMa package, on your MATLAB path. `runScenarios\exampleSimulation` shows how you may use a dataset of weather data (in this case, the Reference Year for Dutch Greenhouses), to run the model with default settings. The plot made here is of the lamp temperatures, but you may plot whatver model component you wish.

The other scenarios in `runScenarios` cannot be run without the data from the Bleiswijk trial, which is not included in this repository. However these examples can be used to run the model with other datasets. You can see in these examples how to compare the model simulations to the measured values, including measured climate variables and energy use.