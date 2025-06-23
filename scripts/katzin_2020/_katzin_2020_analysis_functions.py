"""
GreenLight/scripts/katzin_2020/_katzin_2020_analysis_functions.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions used in the analysis of results of simulation aiming to replicate Katzin (2020).
Used by katzin_2020_generate_output.py

Most of the functions here are Python versions of the MATLAB code used to generate the data in Katzin (2020).
See https://github.com/davkat1/GreenLight/tree/4ec6018e0aad2775ad11085d34f3886a7b7dd052

References:
    Katzin, D., van Mourik, S., Kempkes, F., & van Henten, E. J. (2020). GreenLight – An open source model for
        greenhouses with supplemental lighting: Evaluation of heat requirements under LED and HPS lamps.
        Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010
    Katzin, D. (2021). Energy Saving by LED Lighting in Greenhouses : A Process-Based Modelling Approach.
        PhD thesis, Wageningen University. https://doi.org/10.18174/544434
"""

import numpy as np

"""Air humidity functions - based on old GreenLight files"""


def rh_to_vapor_dens(temp, rh):
    """
    Convert air temperature and relative humidity to vapor density.
    Calculation based on http://www.conservationphysics.org/atmcalc/atmoclc2.pdf
    See:
    https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/serviceFunctions/rh2vaporDens.m

    :param temp: Air temperature (°C)
    :param rh: Air relative humidity (%)
    :return: Air vapor density (kg m**-3)
    """
    r = 8.3144598  # Molar gas constant (J mol**-1 K**-1)
    celsius_to_kelvin = 273.15  # Conversion from Celsius to Kelvin (K)
    mm_water = 18.01528e-3  # Molar mass of water (kg mol**-1)

    # Parameters used in the conversion
    p = [610.78, 238.3, 17.2694, -6140.4, 273, 28.916]

    # Saturation vapor pressure of air in given temperature (Pa)
    saturation_pressure = p[0] * np.exp(p[2] * temp / (temp + p[1]))

    # Partial pressure of vapor in air (Pa)
    pascals = (rh / 100) * saturation_pressure

    # Convert to density using the ideal gas law pV=nRT => n=pV/RT
    # so n=p/RT is the number of moles in a m^3, and mm_water*n=mm_water*p/(R*T) is the
    # number of kg in a m**3, where mm_water is the molar mass of water.
    vapor_dens = pascals * mm_water / (r * (temp + celsius_to_kelvin))

    return vapor_dens


def vapor_dens_to_pressure(temp, vapor_dens):
    """
    Convert air temperature and vapor density to partial vapor pressure.
    Calculation based on http://www.conservationphysics.org/atmcalc/atmoclc2.pdf
    See
    https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/serviceFunctions/vaporDens2pres.m

    :param temp: Air temperature (°C)
    :param vapor_dens: Air vapor density (kg m**-3)
    :return: Air partial vapor pressure (Pa)
    """
    # Parameters used in the conversion
    p = [610.78, 238.3, 17.2694, -6140.4, 273, 28.916]

    # Relative humidity (0-1)
    rh = vapor_dens / rh_to_vapor_dens(temp, 100)

    # Saturation vapor pressure of air in given temperature (Pa)
    saturation_pressure = p[0] * np.exp(p[2] * temp / (temp + p[1]))

    # Partial pressure of vapor in air (Pa)
    vapor_pressure = saturation_pressure * rh

    return vapor_pressure


"""Energy calculation functions - based on old GreenLight files"""
# This is slightly convoluted, but repeated here to replicate 2020 publication


def pipe_t_2_energy_in(diameter, delta_t, pipe_length):
    """
    Calculate energy input to a greenhouse according to pipe properties and difference between air and pipe temperature.
    Based on Verveer, J.B. (1995). Handboek Verwarming Glastuinbouw (Poeldijk: Nutsbedrijf Westland N.V.).
    Note that currently evaluation for deltaT<12 is pretty bad
    See
    https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/postSimAnalysis/pipeT2EnergyIn.m

    :param diameter: Pipe diameter (mm)
    :param delta_t: Difference between air and pipe temperature (°C)
    :param pipe_length: Length of pipe in greenhouse (m)
    :return: Amount of energy given through the pipes to the greenhouse (W)
    """

    # Table from Verveer, J.B. (1995). Handboek Verwarming Glastuinbouw (Poeldijk: Nutsbedrijf Westland N.V.).
    # First column: pipe diameter(mm)
    # First row: delta T (pipe temperature - air temperature, °C)
    # Each data cell represents the energy input in W per m of pipe length,
    # the energy input for a pipe with a given diameter and a given deltaT.
    # See
    # https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/postSimAnalysis/verveerReadme.txt
    # https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/postSimAnalysis/verveer.mat
    verveer = np.array(
        [
            [0, 0, 12, 17, 22, 27, 32, 37, 42, 47, 52, 57, 62, 67, 72],
            [17, 0, 8, 12, 16, 21, 26, 31, 36, 41, 47, 53, 59, 65, 71],
            [21, 0, 10, 15, 20, 25, 31, 37, 43, 50, 56, 63, 70, 78, 85],
            [26, 0, 12, 18, 24, 30, 37, 44, 52, 60, 68, 76, 85, 93, 103],
            [33, 0, 14, 22, 29, 37, 46, 55, 64, 73, 83, 93, 104, 115, 126],
            [38, 0, 16, 25, 33, 42, 52, 62, 72, 83, 94, 106, 118, 130, 143],
            [42, 0, 18, 27, 36, 46, 57, 68, 79, 91, 103, 115, 128, 142, 156],
            [45, 0, 19, 28, 39, 49, 60, 72, 84, 96, 109, 123, 136, 151, 165],
            [48, 0, 20, 30, 41, 52, 64, 76, 89, 102, 116, 130, 144, 159, 175],
            [51, 0, 21, 32, 43, 55, 67, 80, 93, 107, 122, 137, 152, 168, 185],
            [57, 0, 23, 35, 47, 60, 74, 88, 103, 118, 134, 151, 168, 185, 204],
            [60, 0, 25, 37, 50, 63, 77, 92, 108, 124, 141, 158, 176, 194, 213],
            [63, 0, 26, 38, 52, 66, 81, 96, 113, 129, 147, 165, 183, 203, 222],
            [70, 0, 28, 42, 57, 72, 89, 106, 124, 142, 161, 181, 201, 222, 244],
            [76, 0, 30, 45, 61, 78, 95, 114, 133, 153, 173, 194, 216, 239, 262],
            [83, 0, 33, 49, 66, 84, 103, 123, 144, 165, 187, 210, 234, 258, 284],
            [89, 0, 35, 52, 70, 90, 110, 131, 153, 176, 199, 224, 249, 275, 302],
            [95, 0, 37, 55, 75, 95, 116, 139, 162, 186, 211, 237, 264, 291, 320],
            [102, 0, 40, 59, 80, 101, 124, 148, 172, 198, 225, 252, 281, 310, 341],
            [108, 0, 42, 62, 84, 107, 130, 155, 181, 208, 236, 266, 296, 327, 359],
            [114, 0, 44, 65, 88, 112, 137, 163, 190, 219, 248, 279, 310, 343, 376],
            [121, 0, 46, 69, 93, 118, 144, 172, 201, 231, 262, 294, 327, 361, 397],
            [127, 0, 48, 72, 97, 123, 151, 180, 210, 241, 273, 307, 341, 377, 414],
            [133, 0, 50, 75, 101, 128, 157, 187, 218, 251, 285, 320, 356, 393, 432],
            [140, 0, 53, 78, 106, 134, 164, 196, 229, 263, 298, 335, 372, 412, 452],
            [152, 0, 57, 84, 114, 145, 177, 211, 246, 283, 321, 360, 401, 443, 487],
            [159, 0, 59, 88, 118, 151, 184, 220, 256, 294, 334, 375, 417, 461, 507],
            [165, 0, 61, 91, 122, 156, 191, 227, 265, 304, 345, 388, 431, 477, 524],
            [168, 0, 62, 92, 124, 158, 194, 231, 269, 309, 351, 394, 439, 485, 532],
            [178, 0, 65, 97, 131, 167, 204, 243, 284, 326, 369, 415, 462, 510, 561],
            [194, 0, 71, 105, 142, 180, 220, 262, 306, 352, 399, 448, 499, 551, 606],
            [219, 0, 79, 117, 158, 201, 246, 293, 342, 392, 445, 500, 556, 615, 676],
            [244, 0, 87, 130, 175, 222, 272, 324, 378, 434, 492, 553, 616, 680, 747],
            [267, 0, 94, 140, 189, 240, 294, 350, 408, 469, 532, 598, 665, 735, 808],
        ]
    )

    # Find the closest rows, from above and below, to the given diameter
    diam_idx = np.interp(diameter, verveer[1:, 0], np.arange(1, verveer.shape[0]))
    diam_floor = int(np.floor(diam_idx))
    diam_ceil = int(np.ceil(diam_idx))

    # Calculate the energy for the chosen 2 rows (W m**-1)
    energy_floor = np.interp(delta_t, verveer[0, 1:], verveer[diam_floor, 1:])
    energy_ceil = np.interp(delta_t, verveer[0, 1:], verveer[diam_ceil, 1:])

    # Distance from diam_idx to diam_floor
    dist = diam_idx - diam_floor

    # Interpolate the values from between the 2 rows
    # and multiply by the pipe length (m) to get W
    energy_in = pipe_length * (dist * energy_ceil + (1 - dist) * energy_floor)

    # If deltaT is not positive, no energy is coming in
    energy_in[delta_t <= 0] = 0

    return energy_in


def pipe_energy(delta_t):
    """
    Convert difference between pipe rail and air temperature to greenhouse energy use.
    Based on the properties of the greenhouse where the trial of Katzin (2020) was carried out:
        - Compartment size 144 m**2
        - 166.8 m of 51 mm diameter pipes
        - 6 m of 29 mm diameter pipes
        - 19.2 m of 58 mm diameter pipes
    See
    https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/postSimAnalysis/pipeEnergy.m

    :param delta_t: Difference between pipe and air temperature (°C)
    :return: Calculated energy use (W m**-2)
    """
    return (
        1
        / 144
        * (
            pipe_t_2_energy_in(51, delta_t, 166.8)
            + pipe_t_2_energy_in(29, delta_t, 6)
            + pipe_t_2_energy_in(58, delta_t, 19.2)
        )
    )


def grow_pipe_energy(delta_t):
    """
    Convert difference between grow pipe and air temperature to greenhouse energy use.
    Based on the properties of the greenhouse where the trial of Katzin (2020) was carried out:
        - Compartment size 144 m**2
        - 94.5 m of 35 mm diameter pipes
        - 70 m of 29 mm diameter pipes
        - 9.4 m of 64 mm diameter pipes
        - 37 m of 51 mm diameter pipes
    See
    https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/postSimAnalysis/groPipeEnergy.m

    :param delta_t: Difference between pipe and air temperature (°C)
    :return: Calculated energy use (W m**-2)
    """
    return (
        1
        / 144
        * (
            pipe_t_2_energy_in(35, delta_t, 94.5)
            + pipe_t_2_energy_in(29, delta_t, 70)
            + pipe_t_2_energy_in(64, delta_t, 9.4)
            + pipe_t_2_energy_in(51, delta_t, 37)
        )
    )
