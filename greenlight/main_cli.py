"""
GreenLight/greenlight/main_cli.py
Copyright (c) 2025 Shanaka Prageeth, Keio University, Japan
Modified by David Katzin, Wageningen University & Research
SPDX-License-Identifier: BSD-3-Clause-Clear
This file is part of GreenLight, a simulation framework for greenhouse crop growth.

Execute Greenlight simulation in CLI. However, as this is a CLI interface all user input
should be given before executing this script.
If you like to customize and change data using GUI or after simulation please use GUI application.
See docs/input_data.md
"""

import argparse
import csv
import datetime
import logging
import os

import matplotlib

# Post-processing and visualization
import pandas as pd

from greenlight import GreenLight, convert_energy_plus

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


def _validate_inputs(
    input_data_file,
    sim_length,
    start_date,
    output_file,
    base_path,
    model_file,
    custom_mods,
):
    """
    Validate inputs given from the command line

    Args:
        input_data_file (str): Path to the input data file (CSV).
        sim_length (str): Length of simulated season (in days).
        start_date (str or datetime.date): Start date in 'YYYY-MM-DD' format or as a date object.
        output_file (str): Output file location (CSV).
        base_path (str): Base path for logging.
        model_file (str): Path to the model definition JSON file.
        custom_mods (str): Custom modifications (file path or text).

    Returns:
        dict: Dictionary of all input parameters, resolved to absolute paths and parsed dates.
    """
    # Parse dates if given as strings
    if isinstance(start_date, str):
        start_date = datetime.datetime.strptime(start_date, "%Y-%m-%d").date()
    sim_length = float(sim_length)

    def abspath_or_blank(var):  # Return "" if var is empty, otherwise return os.path.abspath(var)
        return os.path.abspath(var) if var else ""

    result = {
        "input_data": abspath_or_blank(input_data_file),
        "sim_length": sim_length,
        "start_date": start_date,
        "output_file": abspath_or_blank(output_file),
        "base_path": abspath_or_blank(base_path),
        "model": abspath_or_blank(model_file),
        "custom_mods": custom_mods,
    }
    return result


def main():
    parser = argparse.ArgumentParser(description="Run a GreenLight simulation from the command line.")

    # Reasonable defaults
    default_base_path = ""
    default_model_file = ""
    default_input_data_file = ""
    default_output_file = os.path.join(
        "output",
        "tests",
        "greenlight_output_test_" + datetime.datetime.now().strftime("%Y%m%d_%H%M") + ".csv",
    )
    default_start_date = "2021-09-27"
    default_sim_length = "1"
    default_mods = ""

    # Arguments (all optional, but will error if required files are missing)
    parser.add_argument(
        "--input_data_file", type=str, default=default_input_data_file, help="Input data file (CSV, optional)."
    )
    parser.add_argument("--sim_length", type=str, default=default_sim_length, help="Simulation length (in days).")
    parser.add_argument(
        "--start_date", type=str, default=default_start_date, help="Simulation start date (YYYY-MM-DD)."
    )
    parser.add_argument("--output_file", type=str, default=default_output_file, help="Output file location (CSV).")
    parser.add_argument(
        "--base_path", type=str, default=default_base_path, help="Base path for logging (project folder)."
    )
    parser.add_argument(
        "--model_file", type=str, default=default_model_file, help="Path to the model definition JSON file."
    )
    parser.add_argument(
        "--mods", type=str, default=default_mods, help="Custom modifications (file path or text, optional)."
    )

    args = parser.parse_args()

    # Argument verification
    errors = []
    if args.base_path and not os.path.isdir(args.base_path):
        errors.append(f"Base path does not exist: {args.base_path}")
    if args.model_file and not os.path.isfile(args.model_file):
        errors.append(f"Model file does not exist: {args.model_file}")
    if args.input_data_file and not os.path.isfile(args.input_data_file):
        errors.append(f"Input data file does not exist: {args.input_data_file}")
    if float(args.sim_length) <= 0:
        errors.append(f"Simulation length must be a positive number, input value is: {args.sim_length}")
    try:
        datetime.datetime.strptime(args.start_date, "%Y-%m-%d")
    except Exception:
        errors.append(f"Invalid start_date format: {args.start_date} (expected YYYY-MM-DD)")
    if errors:
        for err in errors:
            print("ERROR:", err)
        print("\nExample usage:")
        print(
            "python -m greenlight.main_cli "
            "--input_data_file /workspaces/GreenLight/greenlight/models/katzin_2021/input_data/test_data/Bleiswijk_from_20091020.csv "
            "--sim_length 3"
            "--start_date 2009-10-20 "
            "--base_path /workspaces/GreenLight/greenlight/models "
            "--model_file /workspaces/GreenLight/greenlight/models/katzin_2021/definition/main_katzin_2021.json "
            "--output_file /workspaces/GreenLight/greenlight/models/katzin_2021/output/greenlight_output_test.csv "
            "--mods katzin_2021/definition/lamp_hps_katzin_2021.json"
        )
        exit(1)

    # Collect and validate inputs
    sim_args = _validate_inputs(
        input_data_file=args.input_data_file,
        sim_length=args.sim_length,
        start_date=args.start_date,
        output_file=args.output_file,
        base_path=args.base_path,
        model_file=args.model_file,
        custom_mods=args.mods,
    )

    base_path = sim_args["base_path"]
    sim_length = sim_args["sim_length"] * 86400

    if sim_args["model"]:  # Something was entered as a model file
        model = os.path.relpath(sim_args["model"], base_path)
    else:
        model = ""

    mods = []
    if sim_args["input_data"].endswith(".csv"):
        # An input data file was chosen, test if it is an EnergyPlus CSV
        try:
            logger = logging.getLogger(__name__)
            with open(sim_args["input_data"]) as f:
                data = list(csv.reader(f))
                first_cell = data[0][0]
        except Exception:
            logger.error("Error loading weather input file %r" % (sim_args["input_data"]))
            raise Exception

        if first_cell == "Location Title":  # It is an unformatted EnergyPlus CSV
            # use it with the input dates to create a weather input file
            output_path, _ = os.path.splitext(sim_args["output_file"])
            output_dir, output_file = os.path.split(sim_args["output_file"])
            input_data_path = os.path.join(output_dir, "..", "input_data")
            filename, _ = os.path.splitext(output_file)
            formatted_weather_file = os.path.abspath(os.path.join(input_data_path, filename + "_formatted_weather.csv"))
            weather_path = convert_energy_plus(
                sim_args["input_data"],
                formatted_weather_file,
                sim_args["start_date"],
                sim_args["end_date"],
                output_format="katzin2021",
            )
        else:  # Assume that the file contains data that can be used
            weather_path = sim_args["input_data"]

        # Add the file as a modification to the model run
        if base_path:
            mods = [os.path.relpath(weather_path, base_path)]
        else:
            mods = [weather_path]

    mods.append({"options": {"t_end": sim_length}})
    mods.append(sim_args["custom_mods"])

    if base_path:
        output = os.path.relpath(sim_args["output_file"], base_path)
    else:
        output = sim_args["output_file"]
    full_dir = os.path.dirname(output)
    os.makedirs(full_dir, exist_ok=True)

    # Create the model instance
    mdl = GreenLight(base_path=base_path, optional_prompt=[model, mods], output_path=output)

    # Load, solve, and save. Note: these 3 lines can be replaced by mdl.run()
    mdl.load()
    mdl.solve()
    mdl.save()

    # Determine output file absolute path
    output_abs_path = os.path.join(base_path, output)
    output_df = pd.read_csv(output_abs_path, header=None, low_memory=False)
    variable_names = output_df.iloc[0]
    descriptions = output_df.iloc[1]
    units = output_df.iloc[2]

    # Reformat the DataFrame with variable names as columns
    output_df = output_df.iloc[3:].reset_index(drop=True)
    output_df.columns = variable_names
    output_df = output_df.apply(pd.to_numeric)

    # Create dictionaries for descriptions and units
    descriptions_dict = dict(zip(variable_names, descriptions))
    units_dict = dict(zip(variable_names, units))

    # Show some graphs
    chosen_vars = [var for var in ["tOut", "tAir", "tCan"] if var in output_df.columns]

    # Save plots to the same directory as the output file
    plots_dir = os.path.join(os.path.dirname(output_abs_path), "plots")
    os.makedirs(plots_dir, exist_ok=True)

    for var in chosen_vars:
        fig, ax = plt.subplots()
        output_df.plot(
            x="Time",
            y=var,
            xlabel="Time (s)",
            ylabel=f"{var} ({units_dict.get(var, '')})",
            title=descriptions_dict.get(var, var),
            legend=None,
            ax=ax,
        )
        headless = matplotlib.get_backend().lower() == "agg"
        plot_path = os.path.join(plots_dir, f"{var}.png")
        fig.savefig(plot_path)
        print(f"Plot for {var} saved to {plot_path}")
        plt.close(fig)
        if not headless:
            plt.show()

    # Calculate yield, energy use, CO2 use, water use
    time_step = output_df["Time"].iloc[1] - output_df["Time"].iloc[0]
    print(f"Time step size: {time_step} seconds")
    print(f'Simulation length: {(output_df["Time"].iloc[-1] - output_df["Time"].iloc[0]) / 86400} days')

    dmc = 0.06  # Assumed fruit dry matter content

    # Total yield, kg fresh weight per m**2
    if "mcFruitHar" in output_df.columns:
        tot_yield = time_step * output_df["mcFruitHar"].sum() * 1e-6 / dmc
        print(f"Yield: {tot_yield} kg/m2")

    # Energy for heating, MJ m**2
    heat_cols = [col for col in ["hBoilPipe", "hBoilGroPipe"] if col in output_df.columns]
    if heat_cols:
        energy_heat = time_step * sum(output_df[col].sum() for col in heat_cols) * 1e-6
        print(f"Energy used for heating: {energy_heat} MJ/m2")

    # Energy for lighting, MJ m**2
    light_cols = [col for col in ["qLampIn", "qIntLampIn"] if col in output_df.columns]
    if light_cols:
        energy_light = time_step * sum(output_df[col].sum() for col in light_cols) * 1e-6
        print(f"Energy used for lighting: {energy_light} MJ/m2")

    # Total CO2 use (for CO2 injection), kg m**2
    if "mcExtAir" in output_df.columns:
        tot_co2 = time_step * output_df["mcExtAir"].sum() * 1e-6
        print(f"CO2 use: {tot_co2} kg/m2")

    # Water use for irrigation, liters/m2
    if "mvCanAir" in output_df.columns:
        trans_to_irrig = 1.1
        tot_h20 = time_step * trans_to_irrig * output_df["mvCanAir"].sum()
        print(f"Water use for irrigation: {tot_h20} liters/m2")


if __name__ == "__main__":
    main()
