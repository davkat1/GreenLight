"""
GreenLight/greenlight/_save/core.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions for saving a GreenLightModel simulation (i.e., a solved model) and related logs to files.

Public functions:
    save_sim(mdl: GreenLightModel) -> None:
        Save the simulation and related logs of a GreenLightModel in files

Example usage:
    >>> from greenlight._greenlight_internal import GreenLightInternal
    >>> mdl = GreenLightInternal("C:\\Models", "my_model.json")
    >>> load_model(mdl)
    >>> save_sim(mdl)

External dependencies:
    - numpy: for working with numerical arrays
    - pandas: for _save data to CSV files
"""

import json
import os

import numpy as np
import pandas as pd

from greenlight._greenlight_internal import GreenLightInternal


def save_sim(mdl: GreenLightInternal) -> None:
    """
    Save a GreenLightInternal simulation to files. It is assumed that a simulation was run, i.e., the model was solved,
    using greenlight.solve_model. The location of the saved files is based on mdl.output_path.

    The following mdl attributes influence the working of this function:
        - mdl.output_path: Assumed to be a str. The output will be saved in CSV format to this location
            If it is empty (default value of GreenLightInternal constructor), no output files will be saved
        - mdl.options["output_step"]: The CSV output will be interpolated so that the time steps are equal to this value
        - mdl.options["interpolation"]: If "linear", the interpolation for creating the desired output step will be
            linear. Otherwise, "nearest neighbor" to the left will be used.

    The following attributes of mdl are modified:
        - mdl.full_sol is updated with the interpolated values

    The output CSV file will have the following format:
        - First row is the names of all variables in mdl.full_sol, and the first variable is Time
        - Second row is the variable descriptions
        - Third row is the variable units
        - Following rows are the time trajectories of the variables

    Additionally, the following files are created in the same folder as the output CSV:
        - <file_name>_model_struct_log.json: A JSON file representing the structure of the model used in the simulation,
            following the greenlight model format (see docs/model_format.md)
        - <file_mame>_simulation_log.txt: A text file of the simulation log, from the creation of the GreenLightInternal
            object until the moment of saving

    Here, <file_name> is the name of the file in mdl.output_path, excluding the file extension.

    :param mdl:
    :return:
    """

    # Interpolate the solution according to the desired output step size
    time_stamps = mdl.full_sol["Time"]
    output_step = float(mdl.options["output_step"])
    interpolated_time_stamps = np.arange(time_stamps.iloc[0], time_stamps.iloc[-1], output_step)
    interpolated_sol = pd.DataFrame(columns=mdl.full_sol.columns)

    units_df = pd.DataFrame(columns=mdl.full_sol.columns, dtype="object")
    desc_df = pd.DataFrame(columns=mdl.full_sol.columns, dtype="object")

    for col in interpolated_sol:
        if col == "Time":
            interpolated_sol[col] = interpolated_time_stamps
        else:
            if mdl.options["interpolation"] == "linear":
                interpolated_sol[col] = np.interp(interpolated_time_stamps, mdl.full_sol["Time"], mdl.full_sol[col])
            else:  # Default is "left"
                rows = mdl.full_sol["Time"].searchsorted(interpolated_time_stamps)
                rows = np.clip(rows, 0, mdl.full_sol.shape[0] - 1)
                interpolated_sol[col] = mdl.full_sol.loc[rows, col].reset_index(drop=True)
        if col in mdl.var_units:
            units_df.loc[0, col] = mdl.var_units[col]
        else:
            units_df.loc[0, col] = "no_unit_defined"
        if col in mdl.var_descriptions:
            desc_df.loc[0, col] = mdl.var_descriptions[col]
        else:
            desc_df.loc[0, col] = "no_description"

    mdl.full_sol = interpolated_sol

    if mdl.output_path:
        save_success = _try_saving(
            pd.concat([desc_df, units_df, interpolated_sol], ignore_index=True), mdl.base_path, mdl.output_path
        )
        if save_success:
            mdl.add_to_log(f"Output saved to file {mdl.output_path}", warn=False)
        file_path, _ = os.path.splitext(mdl.output_path)
        model_struct_path = file_path + "_model_struct_log.json"
        sim_log_path = file_path + "_simulation_log.txt"
        with open(os.path.join(mdl.base_path, model_struct_path), "w", encoding="utf-8") as outfile:
            json.dump(_create_model_dict(mdl), outfile, indent=4, ensure_ascii=False)
        mdl.add_to_log(f"Model structure log saved to {model_struct_path}", warn=False, to_print=True)

        mdl.add_to_log(f"Simulation log saved to {sim_log_path}", warn=False, to_print=True)
        with open(os.path.join(mdl.base_path, sim_log_path), "w") as outfile:
            outfile.write(mdl.log)


def _create_model_dict(mdl: GreenLightInternal) -> dict:
    """
    Create a dict of the model structure in mdl, following the greenlight model formar.
    The returned dict has the following format:
        - Its keys are the names of all keys in mdl.variables and mdl.functions
        - Each key has a value that is a dict with the following keys and values:
            - "definition": The variable definition (mdl.variables[key] if it exists, otherwise "")
            - "formatted definition": The formatted variable definition (mdl.variables_formatted[key] if it exists,
                otherwise "")
            - "type": The variable type ("function", "state", "input", "const", or "aux")
            - "unit": The variable unit (mdl.var_units[key] if it exists, otherwise "no unit defined")
            - "description": The variable description (mdl.var_descriptions[key] if it exists, otherwise "")
            - "reference": The variable reference (mdl.var_refs[key] if it exists, otherwise "")

    :param mdl: A GreenLightInternal instance with a loaded model
    :return: A dict representing the model in mdl, following to the greenlight model format (see above)
    """
    info = "Automatically generated model structure log. See accompanying simulation log for more info"
    model_dict = {"info": info, "constants": {}, "states": {}, "auxiliary states": {}, "inputs": {}, "functions": {}}
    for key in (mdl.variables | mdl.functions).keys():
        node = {
            "definition": mdl.variables[key] if key in mdl.variables else "",
            "formatted definition": mdl.variables_formatted[key] if key in mdl.variables_formatted else "",
            "type": "",
            "unit": mdl.var_units[key] if key in mdl.var_units else "no unit defined",
            "description": mdl.var_descriptions[key] if key in mdl.var_descriptions else "",
            "reference": mdl.var_refs[key] if key in mdl.var_refs else "",
        }
        if key in mdl.functions:
            key_type = "function"
            sub_dict = "functions"
        elif key in mdl.states:
            key_type = "state"
            sub_dict = "states"
        elif key in mdl.inputs:
            key_type = "input"
            sub_dict = "inputs"
        elif key in mdl.consts:
            key_type = "const"
            sub_dict = "constants"
        else:
            key_type = "aux"
            sub_dict = "auxiliary states"

        node["type"] = key_type
        model_dict[sub_dict][key] = node

    if not model_dict["constants"]:
        del model_dict["constants"]
    if not model_dict["states"]:
        del model_dict["states"]
    if not model_dict["auxiliary states"]:
        del model_dict["auxiliary states"]
    if not model_dict["inputs"]:
        del model_dict["inputs"]
    if not model_dict["functions"]:
        del model_dict["functions"]

    model_dict["options"] = mdl.options
    return model_dict


def _try_saving(df_to_save: pd.DataFrame, base_path: str, file_path: str) -> bool:
    """
    Try saving a pandas DataFrame to a CSV file. If the CSV file is locked (e.g., if it is open in Excel), the method
    will allow retry, rename the file, or abort. The method will continue until saving is succeeded or aborted.

    :param df_to_save: pandas DataFrame to _save to file
    :param base_path: Path to use as a basis - the file will be saved to os.path.join(base_path, file_path)
    :param file_path: Path where to _save the DataFrame in CSV fromat
    :return: True if the file was saved, False if saving was aborted
    """
    while True:  # Try saving the file
        try:
            # Create the directory if it does not exist
            full_dir = os.path.dirname(os.path.join(base_path, file_path))
            os.makedirs(full_dir, exist_ok=True)
            df_to_save.to_csv(os.path.join(base_path, file_path), encoding="utf-8-sig", index=False)
            print(f"Output saved to file {file_path}")
            return True
        except PermissionError:
            print(f"Cannot save to {file_path}.\n" f"The file is currently open or locked.")
            choice = (
                input(
                    "To retry saving, type S. "
                    "To rename the output file, type R. "
                    "To abort without saving, type A: "
                )
                .strip()
                .lower()
            )
            while True:  # Get a valid input from user
                if choice == "s":
                    break
                if choice == "a":
                    return False
                if choice == "r":
                    file_path = input("Enter a new file name: ")
                    break
                else:
                    choice = (
                        input(
                            "Invalid input. "
                            "To retry saving, type S. "
                            "To rename the output file, type R. "
                            "To abort without saving, type A: "
                        )
                        .strip()
                        .lower()
                    )
