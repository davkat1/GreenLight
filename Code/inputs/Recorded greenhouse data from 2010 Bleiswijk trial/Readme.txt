This folder is used to store data from greenhouse trials performed in Bleiswijk, The Netherlands, in 2009-2010.:
	dataHPS.mat - data from a greenhouse compartment with HPS lamps
	dataLED.mat - data from a greenhouse compartment with LED lamps
	
This data is not included in a git repository, but can be accessed through the 4TU.ResearchData repository:
	"Data from: ‘GreenLight - An open source model for greenhouses with supplemental lighting: Evaluation of heat requirements under LED and HPS lamps’" (Katzin et al., 2024)
	DOI: 10.4121/78968e1b-eaea-4f37-89f9-2b98ba3ed865
	URL: https://doi.org/10.4121/78968e1b-eaea-4f37-89f9-2b98ba3ed865
	See the Readme and methodology files of the full dataset for more information

Instructions:
	1. Go to https://doi.org/10.4121/78968e1b-eaea-4f37-89f9-2b98ba3ed865
	2. Download 'Processed data.zip'
	3. Unzip the file and place its contents here
	
Once dataHPS.mat and dataLED.mat are placed in this folder, they can be used for running the model evaluation simulations:
	Code/runScenarios/evaluateEnergyUseHps.m
	Code/runScenarios/evaluateEnergyUseLed.m
	Code/runScenarios/evaluateClimateModelHps.m
	Code/runScenarios/evaluateClimateModelLed.m

These are the simulations performed for Katzin et al., (2020). GreenLight – An open source model for greenhouses with supplemental lighting: Evaluation of heat requirements under LED and HPS lamps. Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010

This readme file was written September 2024
David Katzin, Wageningen University, david.katzin@wur.nl