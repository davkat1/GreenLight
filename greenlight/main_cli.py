"""
GreenLight/greenlight/main_cli.py
Copyright (c) 2025 Shanaka Prageeth, Keio University, Japan
SPDX-License-Identifier: BSD-3-Clause-Clear
This file is part of GreenLight, a simulation framework for greenhouse crop growth.

Execute Greenligh simulation in CLI. However, as this is a CLI interface all user input should given before executing this script.
if you like to customize and change data using GUI or after simulation please use GUI application. See docs/input_data.md
"""

import argparse
import datetime
import os

import matplotlib
import matplotlib.pyplot as plt

# Post-processing and visualization
import pandas as pd

from . import GreenLight, convert_energy_plus


def run_simulation_cli(
    base_path,
    model_file,
    input_data_file,
    start_date,
    end_date,
    mods,
    output_file,
):
    """
    Run a GreenLight simulation with the given parameters.

    Args:
        base_path (str): Base path for logging.
        model_file (str): Path to the model definition JSON file.
        input_data_file (str): Path to the input data file (CSV).
        start_date (str or datetime.date): Start date in 'YYYY-MM-DD' format or as a date object.
        end_date (str or datetime.date): End date in 'YYYY-MM-DD' format or as a date object.
        mods (str): Custom modifications (file path or text).
        output_file (str): Output file location (CSV).
    Returns:
        dict: Dictionary of all input parameters, resolved to absolute paths and parsed dates.
    """
    # Parse dates if given as strings
    if isinstance(start_date, str):
        start_date = datetime.datetime.strptime(start_date, "%Y-%m-%d").date()
    if isinstance(end_date, str):
        end_date = datetime.datetime.strptime(end_date, "%Y-%m-%d").date()

    result = {
        "base_path": os.path.abspath(base_path),
        "model": os.path.abspath(model_file),
        "input_data": os.path.abspath(input_data_file) if input_data_file else "",
        "start_date": start_date,
        "end_date": end_date,
        "mods": mods,
        "output_file": os.path.abspath(output_file),
    }
    return result


def main():
    parser = argparse.ArgumentParser(description="Run a GreenLight simulation from the command line.")
    file_dir = os.path.dirname(os.path.abspath(__file__))
    models_dir = os.path.abspath(os.path.join(file_dir, "..", "models"))

    # Reasonable defaults
    default_base_path = models_dir
    default_model_file = os.path.join(models_dir, "katzin_2021", "definition", "main_katzin_2021.json")
    default_input_data_file = os.path.join(
        models_dir, "katzin_2021", "input_data", "energyPlus_original", "NLD_Amsterdam.062400_IWECEPW.csv"
    )
    default_output_file = os.path.join(
        models_dir,
        "katzin_2021",
        "output",
        "greenlight_output_" + datetime.datetime.now().strftime("%Y%m%d_%H%M") + ".csv",
    )
    default_start_date = "2021-09-27"
    default_end_date = "2022-09-12"
    default_mods = os.path.join("katzin_2021", "definition", "lamp_hps_katzin_2021.json")

    # Arguments (all optional, but will error if required files are missing)
    parser.add_argument(
        "--base_path", type=str, default=default_base_path, help="Base path for logging (project folder)."
    )
    parser.add_argument(
        "--model_file", type=str, default=default_model_file, help="Path to the model definition JSON file."
    )
    parser.add_argument("--output_file", type=str, default=default_output_file, help="Output file location (CSV).")
    parser.add_argument(
        "--start_date", type=str, default=default_start_date, help="Simulation start date (YYYY-MM-DD)."
    )
    parser.add_argument("--end_date", type=str, default=default_end_date, help="Simulation end date (YYYY-MM-DD).")
    parser.add_argument(
        "--input_data_file", type=str, default=default_input_data_file, help="Input data file (CSV, optional)."
    )
    parser.add_argument(
        "--mods", type=str, default=default_mods, help="Custom modifications (file path or text, optional)."
    )

    args = parser.parse_args()

    # Argument verification
    errors = []
    if not os.path.isdir(args.base_path):
        errors.append(f"Base path does not exist: {args.base_path}")
    if not os.path.isfile(args.model_file):
        errors.append(f"Model file does not exist: {args.model_file}")
    if args.input_data_file and not os.path.isfile(args.input_data_file):
        errors.append(f"Input data file does not exist: {args.input_data_file}")
    try:
        datetime.datetime.strptime(args.start_date, "%Y-%m-%d")
    except Exception:
        errors.append(f"Invalid start_date format: {args.start_date} (expected YYYY-MM-DD)")
    try:
        datetime.datetime.strptime(args.end_date, "%Y-%m-%d")
    except Exception:
        errors.append(f"Invalid end_date format: {args.end_date} (expected YYYY-MM-DD)")
    if errors:
        for err in errors:
            print("ERROR:", err)
        print("\nExample usage:")
        print(
            "python -m greenlight.main_cli "
            "--base_path /workspaces/GreenLight/models "
            "--model_file /workspaces/GreenLight/models/katzin_2021/definition/main_katzin_2021.json "
            "--output_file /workspaces/GreenLight/models/katzin_2021/output/greenlight_output_20240613_1200.csv "
            "--start_date 1983-01-01 "
            "--end_date 1983-01-02 "
            "--input_data_file /workspaces/GreenLight/models/katzin_2021/input_data/energyPlus_original/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv "
            "--mods katzin_2021/definition/lamp_hps_katzin_2021.json"
        )
        exit(1)

    # Collect and validate inputs
    sim_args = run_simulation_cli(
        base_path=args.base_path,
        model_file=args.model_file,
        input_data_file=args.input_data_file,
        start_date=args.start_date,
        end_date=args.end_date,
        mods=args.mods,
        output_file=args.output_file,
    )

    base_path = sim_args["base_path"]
    model = os.path.relpath(sim_args["model"], base_path)
    sim_length = (sim_args["end_date"] - sim_args["start_date"]).total_seconds()

    mods = []
    if sim_args["input_data"].endswith(".csv") and sim_args["input_data"]:
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
        mods = [os.path.relpath(weather_path, base_path)]

    mods.append({"options": {"t_end": sim_length}})
    if sim_args["mods"]:
        mods.append(sim_args["mods"])

    output = os.path.relpath(sim_args["output_file"], base_path)

    # Create the model instance
    mdl = GreenLight(base_path=base_path, input_prompt=[model, mods], output_path=output)

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
