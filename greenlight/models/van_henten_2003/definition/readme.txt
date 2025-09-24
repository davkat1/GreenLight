GreenLight/greenlight/models/van_henten_2003/definition/
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Files for running the Van Henten (2003) greenhouse model in the greenlight platform.

In this folder:
    greenhouse_evh2003.json
        The greenhouse model as described in Van Henten (2003). The original Van Henten model was designed to perform optimal control of the greenhouse climate. In this file, the climate controls are set as constant. Weather data is also set to constant.
        This file may be run as standalone, but control and weather data are constant so results are not very meaningful
    main_evh2003_constant_control.json
        Model setup that uses greenhouse_evh2003.json, but also loads a weather data file into the simulation. See van_henten_2003\readme.txt for information on how to obtain weather data and format it according to the required format
    main_evh2003_setpoint_control.json
        Model setup that uses greenhouse_evh2003.json, but also loads a weather data file, and setpoint-based climate control in the greenhouse. Control is done by using a smoothed proportional controller, following Katzin et al. (2021).
    control_setpoints.json
        The file that defines the smoothed proportional controllers, used in main_evh2003_setpoint_control.json

Usage:
    The following files can be provided as input arguments to greenlight:
    greenhouse_evh2003.json
        Run a greenhouse model with constant weather and control
    main_evh2003_constant_control.json
        Run a greenhouse model with loaded weather data and constant control
    main_evh2003_setpoint_control.json
        Run a greenhouse model with loaded weather data and setpoint-based control

References:
    Van Henten (2003). Sensitivity Analysis of an Optimal Control Problem in Greenhouse Climate Management. Biosystems Engineering, 85(3), 355-364. https://doi.org/10.1016/S1537-5110(03)00068-0
    Katzin, Marcelis, Van Mourik (2021). Energy Savings in Greenhouses by Transition from High-Pressure Sodium to LED Lighting. Applied Energy 281:116019. https://doi.org/10.1016/j.apenergy.2020.116019

Author of these files: David Katzin, Wageningen University and Research. david.katzin@wur.nl
Created: May 2025
