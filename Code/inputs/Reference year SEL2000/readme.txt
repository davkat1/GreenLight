Weather data for a reference year in dutch greenhouses.
Based on: 
Breuer, J. J. G., and N. J. Van de Braak. "Reference year for Dutch greenhouses." In International Symposium on Models for Plant Growth, Environmental Control and Farm Management in Protected Cultivation 248, pp. 101-108. 1988.

Files in this folder:

seljaar.xls
------------
Excel file created by Rachel ven Ooteghem, rachel.vanooteghem@wur.nl

Columns:

A - time since beginning of year [s]
B - outdoor global radiation [W m^{-2}]
C - wind [m/s]
D - air temperature [°C]
E - sky temperature [°C]
F - ?????
G - CO2 concentration [ppm] - assumed to be constant 320, not included in the original Breuer&Braak paper
H - day number
I - relative humidity [%]

seljaar.mat
-----------
A matlab file containting two matrices:

seljaar
-------
Basically the same as the Excel file described above.

Columns:

1 - time since beginning of year [s]
2 - outdoor global radiation [W m^{-2}]
3 - wind [m/s]
4 - air temperature [°C]
5 - sky temperature [°C]
6 - ?????
7 - CO2 concentration [ppm] - assumed to be constant 320 (why?), not included in the original Breuer&Braak paper
8 - day number
9 - relative humidity [%]

seljaarhires
------------
same as seljaar, only the rows have been expanded to describe 5 minute intervals instead of one hour. This has been done using MATLAB's pchip function, with default parameters


This file written by David Katzin, david.katzin@wur.nl, July 2018