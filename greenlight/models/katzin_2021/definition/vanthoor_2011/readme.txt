GreenLight/greenlight/models/katzin_2021/definition/vanthoor_2011/
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Files for running the Vanthoor (2011) greenhouse and tomato crop model in the greenlight platform.

In this folder:
    greenhouse_vanthoor_2011_chapter_8.json
        The greenhouse model as described in Vanthoor (2011), Chapter 8. In this file, there is no crop, climate controls are set as constant, and weather data is set to constant.
        This file may be run as standalone, but results will not be very meaningful
    main_vanthoor_2011.json
        Model setup that uses greenhouse_vanthoor_2011_chapter_8.json, but also includes a crop, climate control, and weather data.
    crop_vanthoor_2011_chapter_9_simplified.json
        The tomato crop model of Vanthoor (2011), Chapter 9, with some simplifications as in Katzin (2021). This file cannot be run on its own, it must be combined with other files (see below).
    main_vanthoor_crop.json
        Model setup for running the tomato crop model without the greenhouse model. Input data is loaded from a weather file, so essentialy it is assumed that the crop is outdoor.
    extension_crop_vanthoor_2011_for_standalone.json
        Addition to the crop model in order to run the crop only. Combined with crop_vanthoor_2011_chapter_9_simplified.json in main_vanthoor_crop.json
    controls_katzin_2021.json
        Climate control settings based on Katzin (2021). Used in main_vanthoor_2011.json.

Usage:
    The following files can be provided as input arguments to greenlight:
    greenhouse_vanthoor_2011_chapter_8.json
        Run a greenhouse model with no crop, constant weather and control
    main_vanthoor_2011.json
        Run a greenhouse model with a tomato crop, loaded weather data and constant control
    main_vanthoor_crop.json
        Run a crop only model with loaded weather data (the crop is assumed to be outdoor)

References:
    Vanthoor, Bram (2011). A model-based greenhouse design method. PhD thesis, Wageningen University. https://edepot.wur.nl/170301,
    Katzin, David (2021). Energy Saving by LED Lighting in Greenhouses: A Process-Based Modelling Approach. PhD thesis, Wageningen University. https://doi.org/10.18174/544434

Authors of these files: David Katzin, Wageningen University and Research. david.katzin@wur.nl
                        Pierre-Olivier Schwarz, Université Laval
                        Joshi Graf, Wageningen University & Research
Created: May 2025
