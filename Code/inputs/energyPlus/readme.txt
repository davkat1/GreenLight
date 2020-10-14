Data in this folder originates from the EnergyPlus website, https://energyplus.net/weather
Retrieved June 2020.

EPW files were converted to CSV files using the EnergyPlus data utility to assisnt in creating EnergyPlus Weather Formatted Data, which is part of the EnergyPlus release 8.1.0 https://energyplus.net/downloads version

CSV files were converted to MAT file using energyPlusCsv2Mat, see help energyPlusCsv2Mat

The MAT files have 2 variables, in the following format:

weather         A matrix with 10 columns, with 1-hour intervals
                in the following format:
       weather(:,1)    timestamps of the input [datenum]
       weather(:,2)    radiation     [W m^{-2}]  outdoor global irradiation 
       weather(:,3)    temperature   [°C]        outdoor air temperature
       weather(:,4)    humidity      [kg m^{-3}] outdoor vapor concentration
       weather(:,5)    co2 [kg{CO2} m^{-3}{air}] outdoor CO2 concentration
       weather(:,6)    wind        [m s^{-1}] outdoor wind speed
       weather(:,7)    sky temperature [°C]
       weather(:,8)    temperature of external soil layer [°C]
       weather(:,9)    radiation sum coming from that sun during this day,
                       i.e., from the previous midnight to the next midnight [MJ m^{-2} day^{-1}]
       weather(:,10)   elevation above sea level [m] (constant value)
hiresWeather    A matrix with 10 columns, with 5-minute intervals, in
                the same format as weather

allLocationsCsv2Mat.m runs energyPlusCsv2Mat on all data files in this folder

This readme file written July 2020, David Katzin, Wageningen University

david.katzin1@gmail.com
david.katzin@wur.nl