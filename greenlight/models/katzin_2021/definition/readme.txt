GreenLight/greenlight/models/katzin_2021/definition/
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Files for running the Katzin (2020, 2021, 2021a) greenhouse and tomato crop model in the greenlight platform.

In this folder:
    extension_greenhouse_katzin_2021_vanthoor_2011.json
        Extension of the Vanthoor (2011) model to create the Katzin (2021) model. The extension adds lamps, grow pipes,
        a blackout screen, and control settings. This file cannot be run on its own, it must be appended to the Vanthoor model,
        see main_katzin_2020.json and main_katzin_2021.json for examples
    main_katzin_2021.json
        Model setup that combines extension_greenhouse_katzin_2021_vanthoor_2011.json with the Vanthoor (2011) model to define a full greenhouse.
        This setup allows to run simulations as in Katzin (2021a).
    modification_katzin_2020_katzin_2021.json
        Modifications to extension_greenhouse_katzin_2021_vanthoor_2011.json that adjust it to recreate the settings for Katzin (2020).
        This file cannot be run on its own, it must be combined with other files, see main_katzin_2020.json
    main_katzin_2020.json
        Model setup that combines modification_katzin_2020_katzin_2021.json with extension_greenhouse_katzin_2021_vanthoor_2011.json
        to define the setup of the Katzin (2020) simulations.
    lamp_hps_katzin_2020.json
        Lamp definitions for HPS lamps as in Katzin (2020). Can be used together with main_katzin_2020.json to simulate a greenhouse with
        HPS lamps instead of LEDs. See scripts/katzin_2020/katzin_2020_run_sims.py for an example.
    lamp_hps_katzin_2021.json
        Lamp definitions for HPS lamps as in Katzin (2021a). Can be used together with main_katzin_2021.json to simulate a greenhouse with
        HPS lamps instead of LEDs. See scripts/katzin_2021/katzin_2021_run_sims.py for an example.

Usage:
    The following files can be provided as input arguments to greenlight:
    main_katzin_2020.json
        Run simulations as in Katzin (2020), emulating the experimental greenhouses of Wageningen University & Research in Bleiswijk, the Netherlands
    main_katzin_2021.json
        Run a greenhouse as in Katzin (2021) - a modern commercial greenhouse with LED lamps
    See scripts/katzin_2020/katzin_2020_run_sims.py and scripts/katzin_2021/katzin_2021_run_sims.py for examples

References:
    Katzin, D., van Mourik, S., Kempkes, F., & van Henten, E. J. (2020). GreenLight – An open source model for greenhouses
        with supplemental lighting: Evaluation of heat requirements under LED and HPS lamps.
        Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010
    Katzin, D. (2021). Energy Saving by LED Lighting in Greenhouses: A Process-Based Modelling Approach.
        PhD thesis, Wageningen University. https://doi.org/10.18174/544434
    Katzin, D., Marcelis, L.F.M., Van Mourik, S. (2021a). Energy Savings in Greenhouses by Transition from
        High-Pressure Sodium to LED Lighting. Applied Energy 281:116019. https://doi.org/10.1016/j.apenergy.2020.116019
    Vanthoor, Bram (2011). A model-based greenhouse design method. PhD thesis, Wageningen University. https://edepot.wur.nl/170301,


Authors of these files: David Katzin, Wageningen University and Research. david.katzin@wur.nl
                        Pierre-Olivier Schwarz, Université Laval
                        Joshi Graf, Wageningen University & Research
Created: May 2025
