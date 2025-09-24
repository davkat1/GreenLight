"""
GreenLight/greenlight/_load.energy_plus.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions for modifying data from EnergyPlus (https://energyplus.net/weather)

Public functions:
    convert_energy_plus(energy_plus_csv_path: str, output_file_path: str, t_out_start: dt.datetime = None,
                        t_out_end: dt.datetime = None, co2_out_ppm: float = 410, output_format: str = "katzin2021")
                        -> str
        Convert an EnergyPlus weather dataset from CSV format (created using EnergyPlus Weather Statistics and
        Conversions program) into a weather dataset in the format specified, in the timespan between
        t_out_start and t_out_end.

Example usage:
    >>> from greenlight import convert_energy_plus
    >>> convert_energy_plus(energy_plus_csv_path,output_file_path,output_format='katzin2021')
        Creates one standard year of data

    >>> import datetime as dt
    >>> from greenlight import convert_energy_plus
    >>> convert_energy_plus(energy_plus_csv_path,output_file_path,t_out_start=dt.datetime(year=2020, month=9, day=27),
            t_out_end=dt.datetime(year=2020, month=9, day=27)+dt.timedelta(days=350),co2_out_ppm=420,
            output_format="katzin2021")
        Creates a dataset starting on 27/9/2020, 350 days long, with an outdoor CO2 concentration of 420 ppm

The input EnergyPlus CSV file can be created in the following way:
    1. Go to https://energyplus.net/weather and find a weather file, download it in EPW format
    2. Go to https://energyplus.net/downloads to download and install EnergyPlus
    3. Use EnergyPlus' "Weather statistics and Conversions" tool to convert the EPW to CSV

Exceptions:
    convert_energy_plus raises a ValueError in case t_out_end is before t_out_start
    convert_energy_plus raises a ValueError if the file in energy_plus_csv_path contains too little rows.
        The file should have hourly data for a whole year, thus at least 8760 rows.
    convert_energy_plus raises a ValueError if it cannot find the ground temperature data in the file.
        It is expected that a row beginning with "Number of Ground Temperature Depths" is present in the file.
        This row should be followed by monthly ground temperature data.

External dependencies:
    - numpy for calculations of weather related variables
    - pandas for creation of dataframe and saving it as CSV

Authors:
    Pierre-Olivier Schwarz, Université Laval
    David Katzin, Wageningen University & Research, david.katzin@wur.nl
May 2025
"""

import csv
import datetime as dt
import os

import numpy as np
import pandas as pd


def convert_energy_plus(
    energy_plus_csv_path: str,
    output_file_path: str,
    t_out_start: dt.datetime = None,
    t_out_end: dt.datetime = None,
    co2_out_ppm: float = 410,
    output_format: str = "katzin2021",
) -> str:
    """
    Convert an EnergyPlus weather file from EnergyPlus CSV format to an input CSV in the format required by GreenLight
    (for the models Katzin 2020, Katzin 2021, or Van Henten 2003), in the time range from t_out_start and t_out_end.

    t_out_start and t_out_end can be any datetime, as long as t_out_end is after t_out_start. Note that the EnergyPlus
    CSV represents a single, "typical", year. This method can create weather datasets that span multiple years
    (and are officially assigned specific year values given by t_out_start and t_out_end), but they will simply be a
    copy of the EnergyPlus year.

    Leap years are not generated - the output file does not contain February 29, even if the desired output
    timespan includes it.

    If t_out_start and t_out_end are not provided, a full year (January 1 - December 31) will be be created, with the
    year value equal to that in the EnergyPlus data's first row.

    The format of the CSV created depends on output_format. If this is "katzin2021" (default),
    it has the following columns:
        Time            Time since beginning of data (s)
        iGlob           Outdoor global horizontal solar radiation (W m**-2)
        tOut            Outdoor air temperature (°C)
        vpOut           Outdoor air vapor pressure (Pa)
        co2Out          Outdoor air CO2 concentration (mg m**-3)
        wind            Outdoor wind speed (m s**-1)
        tSoOut          Deep layer (2 m depth) soil temperature
        dayRadSum       Daily sum of outdoor global radiation (MJ m**-2)
        isDay           1 if it is day out (iGlob>0), 0 if it is night (iGlob==0)
        isDaySmooth     A smoothed version of isDay, but see below

    Note 1: for each time step, dayRadSum gives the radiation sum of that day. Note that in practice it is impossible
    to have such data in real time, since it requires knowledge of the radiation in the day to come.
    Note 2: in the original GreenLight model (v1.x), input data was given in 5 minute intervals. This script creates
    input data in 1-hour intervals, which seem to be sufficient. Therefore, isDay and isDaySmooth are identical,
    and not smoothed at all. They are both equivalent to int(iGlob>0). The "smoothing" (typically a linear
    interpolation) is performed during the model run, for all input data.

    If output_format is "evh2003", the output CSV has the following columns:
        Time            Time since beginning of data (s)
        V_rad           Outdoor global horizontal solar radiation (W m**-2)
        V_T             Outdoor air temperature (°C)
        V_h             Outdoor air humidity concentration (kg m**-3)
        V_c             Outdoor air CO2 concentration (kg m**-3)

    If output_format is "vanthoor_crop", the output CSV has the following columns:
        Time            Time since beginning of data (s)
        parGh           PAR above the canopy (µmol m**-2 s**-1).
                        Assumed to be equal to 2.3 times outdoor global radiation in W m**-2, which
                        is representative of an outdoor crop)
        tCan            Canopy temperature (assumed to be equal to outdoor air temperature, °C)
        co2InPpm        Air CO2 concentration (assumed to be equal to outdoor CO2 concentration, ppm)
    Note 3: the "vanthoor_crop" format generates a quite artificial dataset, where it is assumed that canopy temperature
    is equal to outdoor temperature, and all outdoor PAR is absorbed by the canopy.

    Note 4: the generated file contains time stamps in seconds, starting from 0 at the beginning of the data.
        The file does not contain any information about the dates that the data actually represents. The required
        file name is appended with "from_{start_time}" where start_time is t_out_start, without the year
        (as all years in the output are the same anyway)

    :param energy_plus_csv_path: (str) path to the EnergyPlus CSV file containing the data.
        This file needs to be created using EnergyPlus' Weather Statistics and Conversions program, see above
    :param output_file_path: (str) path to the output file that will be created. If the folders in this path don't
        exist, they will be created
    :param t_out_start: (datetime.datetime, optional) start of the time interval that will be simulated,
        this can be any date
    :param t_out_end: (datetime.datetime, optional) end of the time interval that will be simulated
    :param co2_out_ppm: (scalar number, optional) assumption about outdoor CO2 concentration, in ppm. Default: 410
    :param output_format:
        "katzin2021" (default) for an output in the format required by Katzin 2020 or Katzin 2021.
        "evh2003" for an output in the format required by Van Henten 2003.
        "vanthoor_crop" for an output in the format reauired by the Vanthoor 2011 crop model.

    :raises: Value error if t_out_end <= t_out_start
    :raises: ValueError if the file in energy_plus_csv_path contains too little rows.
                The file should have hourly data for a whole year, thus at least 8760 rows.
    :raises: ValueError if the ground temperature data is not found in the file.
                It is expected that a row beginning with "Number of Ground Temperature Depths" is present in the file.
                This row should be followed by monthly ground temperature data.

    :return: The full path of the file created
    """

    # Find the right place to start reading the data. The read data should have 8760 rows

    # Find the number of rows in the file
    with open(energy_plus_csv_path) as f:
        data = list(csv.reader(f))

    last_row = len(data) - 1

    # Check that the last row(s) is not empty
    while last_row >= 0:
        if (
            len(data[last_row]) == 0 or len(data[last_row][0]) == 0  # Last row is blank
        ):  # The first cell in the last row is blank
            last_row -= 1
        else:  # The last row contains data
            break

    if last_row < 8759:
        raise ValueError(
            "Error in EnergyPlus file %r: yearly data is not complete. Expecting 8760 rows of data "
            "(number of hours in a year). The file should also contain some headers, therefore the file should have"
            "more than 8760 rows." % energy_plus_csv_path
        )

    # Open the EnergyPlus file and store the last 8760 rows of data in a dataframe
    df_ep = pd.read_csv(energy_plus_csv_path, header=last_row - 8760, nrows=8760, encoding_errors="ignore")

    # Add a column with hourly deep soil (2 m) data
    df_ep["tSoOut"] = _get_hourly_deep_soil_temperature(energy_plus_csv_path)

    # The EnergyPlus file should have, in cell E2, the elevation in m above sea level
    elevation = pd.read_csv(energy_plus_csv_path, skiprows=1, nrows=1, encoding_errors="ignore", header=None)

    # Add a column with elevation above sea level (m) data
    df_ep["hElevation"] = elevation.iloc[0, 4] * np.ones([len(df_ep), 1])

    # Add a column with daily radiation sum (MJ m**-2)
    df_ep["dayRadSum"] = (
        (3600e-6 * df_ep["Global Horizontal Radiation {Wh/m2}"].to_numpy()).reshape(365, 24).sum(axis=1).repeat(24)
    )

    # The EnergyPlus file should have, in cell A20, the date in format yyyy/mm/dd
    ep_year = dt.datetime.strptime(df_ep.iloc[0, 0], "%Y/%m/%d").year

    # First timestamp in the EnergyPlus file
    df_ep_start = f"{ep_year}-01-01 01:00:00"

    # If t_start or t_end were not given, use the first value of the input file as a start, and a length of 1 year
    if not t_out_start:
        t_out_start = pd.to_datetime(df_ep_start)
    if not t_out_end:
        t_out_end = t_out_start + pd.Timedelta(days=365, hours=-1)

    if t_out_end <= t_out_start:
        raise ValueError(
            "Required endpoint for output dataset %r is before starting point %r" % (t_out_end, t_out_start)
        )

    # Number of calendar years that need to be included in the output data
    n_years = t_out_end.year - t_out_start.year + 1

    # If needed, duplicate the dataframe over multiple years
    df_ep = df_ep.iloc[np.tile(np.arange(len(df_ep)), n_years)].reset_index()

    # Adjust the timestamps of the output df so that they match the desired years
    df_ep_start = f"{t_out_start.year}-01-01 01:00:00"
    df_ep_end = f"{t_out_start.year + n_years}-01-01 00:00:00"

    # EnergyPlus uses 24:00 as the end of the day, but in Pandas, it's 00:00
    # and it's the beginning of the day. That's why we have to add 1 year.
    df_ep_timestep = dt.timedelta(hours=1)
    temp_datetime = pd.date_range(start=df_ep_start, end=df_ep_end, freq=df_ep_timestep)

    # Remove 02-29 if leap year
    df_ep.loc[:, "datetime"] = temp_datetime[~((temp_datetime.month == 2) & (temp_datetime.day == 29))]

    # EnergyPlus uses the timestamp to mark the end of the hour
    # instead shift the timestamps one hour back so it's the start
    df_ep["datetime"] = df_ep["datetime"] - dt.timedelta(hours=1)

    # Cut the dataframe according to the desired beginning and endpoint
    df_ep = df_ep[
        df_ep["datetime"].between(
            pd.Timestamp(t_out_start) - dt.timedelta(hours=1), pd.Timestamp(t_out_end) - dt.timedelta(hours=1)
        )
    ].reset_index()

    # The dataframe to be created
    df_out = pd.DataFrame()
    units = []  # Units of each column
    descs = []  # Description of each column

    # Time, in seconds since beginning of data
    df_out["Time"] = df_ep["datetime"].values.astype(float) // 1e09
    df_out["Time"] = df_out["Time"] - df_out["Time"].iloc[0]
    units.append("s")
    descs.append("Time since start of data")

    if output_format == "evh2003":
        # Global solar radiation
        df_out["V_rad"] = df_ep["Global Horizontal Radiation {Wh/m2}"]
        units.append("W m**-2")
        descs.append("Solar radiation outside the greenhouse")

        # Outdoor temperature
        df_out["V_T"] = df_ep["Dry Bulb Temperature {C}"]
        units.append("°C")
        descs.append("Outdoor temperature")

        # Outdoor humidity concentration
        df_out["V_h"] = _vp_to_dens(
            df_ep["Dry Bulb Temperature {C}"],
            df_ep["Relative Humidity {%}"] / 100 * _sat_vp(df_ep["Dry Bulb Temperature {C}"]),
        )
        units.append("kg m**-3")
        descs.append("Outdoor humidity concentration")

        # Outdoor CO2 concentration
        df_out["V_c"] = _co2_ppm_to_dens(df_ep["Dry Bulb Temperature {C}"], co2_out_ppm)
        units.append("kg m**-3")
        descs.append("Outdoor CO2 concentration")

    elif output_format == "vanthoor_crop":
        # PAR above the canopy
        # Assumed to be equal to 2.3 times outdoor solar PAR radiation (in W m**-2),
        # which is representative of an outdoor crop
        df_out["parGh"] = 2.3 * df_ep["Global Horizontal Radiation {Wh/m2}"]
        units.append("µmol m**-2 s**-1")
        descs.append("PAR above the canopy")

        # Canopy temperature
        # Assumed to be equal to outdoor air temperature
        df_out["tCan"] = df_ep["Dry Bulb Temperature {C}"]
        units.append("°C")
        descs.append("Canopy temperature")

        # CO2 concentration
        # Assumed to be equal to outdoor CO2 concentration
        df_out["co2InPpm"] = co2_out_ppm
        units.append("ppm")
        descs.append("CO2 concentration of the air around the crop")

    else:
        # Global solar radiation
        df_out["iGlob"] = df_ep["Global Horizontal Radiation {Wh/m2}"]
        units.append("W m**-2")
        descs.append("Outdoor global solar radiation")

        # Outdoor temperature
        df_out["tOut"] = df_ep["Dry Bulb Temperature {C}"]
        units.append("°C")
        descs.append("Outdoor temperature")

        # Outdoor vapour pressure
        df_out["vpOut"] = df_ep["Relative Humidity {%}"] / 100 * _sat_vp(df_ep["Dry Bulb Temperature {C}"])
        units.append("Pa")
        descs.append("Outdoor vapor pressure")

        # Outdoor CO2 concentration
        df_out["co2Out"] = 1e6 * _co2_ppm_to_dens(df_ep["Dry Bulb Temperature {C}"], co2_out_ppm)
        units.append("mg m**-3")
        descs.append("Outdoor CO2 concentration")

        # Outdoor wind speed
        df_out["wind"] = df_ep["Wind Speed {m/s}"]
        units.append("m s**-1")
        descs.append("Outdoor wind speed")

        # Sky temperature
        sigma = 5.6697e-8  # Stefan-Boltzmann constant (W m**-2 K**-4)
        kelvin = 273.15  # 0°C in Kelvin (K)

        # It is assumed that tSky is the temperature corresponding
        # to the measured infrared radiation
        # (according to the Stefan-Boltzmann law, radiation = sigma * T**4, with T in Kelvin)
        df_out["tSky"] = (df_ep["Horizontal Infrared Radiation Intensity from Sky {Wh/m2}"] / sigma) ** 0.25 - kelvin
        units.append("°C")
        descs.append("Apparent sky temperature")

        # Deep soil layer temperature
        df_out["tSoOut"] = df_ep["tSoOut"]
        units.append("°C")
        descs.append("Soil temperature at 2 m depth")

        # Daily radiation sum
        df_out["dayRadSum"] = df_ep["dayRadSum"]
        units.append("MJ m**-2")
        descs.append("Daily sum of outdoor global solar radiation")

        # Is day, following GreenLight1.0 (see setGlInput), "day" is when iGlob > 0
        df_out["isDay"] = np.float32(df_ep["Global Horizontal Radiation {Wh/m2}"].to_numpy() > 0)
        units.append("-")
        descs.append("Switch determining if it is day or night. Used for control purposes")

        # There is no need to make an interpolation here - data is in 1 hour, the linear interpolation -
        # which should be equivalent to isDay - is done automatically
        df_out["isDaySmooth"] = df_out["isDay"]
        units.append("-")
        descs.append("Smooth switch determining if it is day or night. Used for control purposes")

        # Elevation
        df_out["hElevation"] = df_ep["hElevation"]
        units.append("m above sea level")
        descs.append("Elevation at location")

    vars_str = str(df_out.columns.to_list()).replace("[", "").replace("]", "").replace("'", "").replace(", ", ",")
    unit_str = str(units).replace("[", "").replace("]", "").replace("'", "").replace(", ", ",")
    desc_str = str(descs).replace("[", "").replace("]", "").replace("'", "").replace(", ", ",")

    filename, extension = os.path.splitext(output_file_path)
    outpath = f"{filename}_from_{t_out_start.strftime('%b_%d_%H%M%S').lower()}{extension}"

    if os.path.dirname(outpath):
        os.makedirs(os.path.dirname(outpath), exist_ok=True)
    with open(outpath, "w", encoding="utf-8") as outfile:
        outfile.write(vars_str + "\n")
        outfile.write(desc_str + "\n")
        outfile.write(unit_str + "\n")

    df_out.to_csv(outpath, mode="a", header=False, index=False, encoding="utf-8")
    print(f"Converted EnergyPlus file:\n{energy_plus_csv_path}\nand saved the results to:\n{outpath}")
    print(
        f"Start date of generated dataset: {t_out_start}\nEnd date of generated dataset: {t_out_end}\nLength: {t_out_end - t_out_start}"
    )
    return outpath


def _get_hourly_deep_soil_temperature(energy_plus_csv_path: str) -> np.array:
    """
    Calculate hourly values for deep soil temperatures, based on data in an input EnergyPlus CSV file

    The EnergyPlus file has monthly data for the deep soil (2 m depth) temperature. This function fits a
    sinosoid function through these 12 data points, to give hourly data of soil temperature that fits a sinosoid curve

    :param energy_plus_csv_path: (str) path to a CSV weather file generated by EnergyPlus
    :return: np.array containing calculated hourly deep soil temperature values

    :raises: ValueError if the ground temperature data is not found in the file.
        It is expected that a row beginning with "Number of Ground Temperature Depths" is present in the file.
        This row should be followed by monthly ground temperature data.
    """
    # Add hourly data for deep soil layer temperature

    # Search for the row where soil temperature is located
    rows_to_test = 25
    for row in range(0, rows_to_test):
        read_row = pd.read_csv(energy_plus_csv_path, skiprows=row, nrows=1, encoding_errors="ignore", header=None)
        if read_row.iloc[0][0] == "Number of Ground Temperature Depths":
            break

    if row == rows_to_test - 1:
        raise ValueError(
            "Error in EnergyPlus file %r: could not find ground temperature data. "
            "It is expected that a row beginning with 'Number of Ground Temperature Depths' is present in the file. "
            "This row should be followed by monthly ground temperature data." % energy_plus_csv_path
        )

    # Read the row in the file where 2m soil depth temperature should be
    soil_2m_temp = pd.read_csv(energy_plus_csv_path, skiprows=row + 1, nrows=1, encoding_errors="ignore", header=None)
    y = soil_2m_temp.iloc[0, 21:33].to_numpy()
    y_max = np.max(y)
    y_min = np.min(y)
    y_range = y_max - y_min
    y_shift = y - y_max + y_range / 2
    y_mean = np.mean(y)

    x = np.arange(0.5, 12.5, 1)
    zeros_x = x[(y_shift * np.roll(y_shift, 1)) <= 0]
    period = 2 * np.mean(np.diff(zeros_x))

    def sinosoid(x, p0, p1, p2):
        return p0 * np.sin(2 * np.pi * x / period + 2 * np.pi / p1) + p2

    from scipy.optimize import curve_fit

    popt, pcov = curve_fit(sinosoid, x, y, p0=[y_range, -1, y_mean])

    x_p = np.linspace(start=0, stop=12, num=24 * 365)
    y_p = sinosoid(x_p, popt[0], popt[1], popt[2])

    return y_p


def _sat_vp(temperature):
    """
    Compute saturated vapour pressure (in Pa) at a given temperature (in °C).
    Based on the function satVp.m in the Greenlight1.0 model
    (https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/serviceFunctions/satVp.m)
    See also http://www.conservationphysics.org/atmcalc/atmoclc2.pdf

    :param temperature: (float or numpy.ndarray) air dry bulb temperature (°C)
    :return: (float or numpy.ndarray) saturated vapour pressure (Pa)
    """

    # Parameters used in the conversion
    p = [610.78, 238.3, 17.2694, -6140.4, 273, 28.916]

    # Saturation vapor pressure of air in given temperature (Pa)
    return p[0] * np.exp(p[2] * temperature / (temperature + p[1]))


def _vp_to_dens(temperature, vp):
    """
    Compute air humidity density (in kg m**-3) at a given temperature (in °C) and vapor pressure (in Pa)
    Based on the functions vp2dens.m and rh2vaporDens in the Greenlight1.0 model
    (https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/serviceFunctions/vp2dens.m,
    https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/serviceFunctions/rh2vaporDens.m)
    See also http://www.conservationphysics.org/atmcalc/atmoclc2.pdf

    :param temperature: (float or numpy.ndarray) air dry bulb temperature (°C)
    :param vp: (float or numpy.ndarray) air vapour pressure (Pa)
    :return: (float or numpy.ndarray) air humidity density (kg m**-3)
    """

    # Constants
    r = 8.3144598  # molar gas constant (J mol**-1 K**-1)
    c_to_k = 273.15  # conversion from Celsius to Kelvin (K)
    m_water = 18.01528e-3  # molar mass of water (kg mol**-1)

    # convert to density using the ideal gas law pV = nRT = > n = pV / RT
    # so n = p / RT is the number of moles in 1 m**3, and Mw * n = Mw * p / (R * T) is the
    # number of kg in 1 m**3, where Mw is the molar mass of water
    return vp * m_water / (r * (temperature + c_to_k))


def _co2_ppm_to_dens(temperature_values, co2_ppm, r=8.314, m_co2=44.01e-03, p_air=101325.0):
    """
    Convert CO2 concentration in ppm to CO2 density in kg m**-3.
    Based on the function co2pp2dens.m in the Greenlight1.0 model
    (https://github.com/davkat1/GreenLight/blob/4ec6018e0aad2775ad11085d34f3886a7b7dd052/Code/serviceFunctions/co2ppm2dens.m)

    :param temperature_values: (float or numpy.ndarray) temperature (°C)
    :param co2_ppm: (float or numpy.ndarray): CO2 concentration (ppm)
    :param r: (float, optional): ideal gas constant. Defaults to 8.314 J mol**-1 K**-1
    :param m_co2: (float, optional): molar mass of CO2. Defaults to 44.01E-03 kg mol**-1
    :param p_air: (float, optional): Outdoor air pressure. Defaults to 101325.0 Pa.

    :return: float or numpy.ndarray: CO2 density (kg m**-3)
    """

    return p_air * 1e-06 * co2_ppm * m_co2 / (r * (temperature_values + 273.15))
