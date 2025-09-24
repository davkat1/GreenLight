"""
GreenLight/greenlight._load.core.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions for loading a model description from input files, dicts, and strings into a GreenLightModel object.

Public functions:
    load_model(mdl: GreenLightModel) -> None:
        Load a GreenLightModel object based on the information in mdl.input_prompt

Example usage:
    >>> from greenlight._greenlight_internal import GreenLightInternal
    >>> mdl = GreenLightInternal("C:\\Models", "my_model.json")
    >>> load_model(mdl)

Exceptions:
    ValueError if things went wrong during loading:
        - A variable is defined twice in the same JSON file
        - A circular dependency in the variables (a is defined by b which is defined by a) is found
        - Mismatched parentheses
        - Mismatch in number of parameters between a model function call and its definition
        - A model function call exists without a function definition
        - Other errors during parsing

External dependencies:
    - numpy: for numeric interpolation and clipping
    - pandas: for representing data from input CSV files
"""

import importlib.resources as resources
import json
import logging
import os
from pathlib import Path, PurePath

import numpy as np
import pandas as pd

from greenlight._greenlight_internal import GreenLightInternal

from . import _parse_model, _utils


def load_model(mdl: GreenLightInternal) -> None:
    """
    Load and parse a GreenLightInternal based on the object's input_prompt attribute.
    input_prompt can be defined by the constructor, see greenlight.GreenLightInternal().
    If mdl.input_prompt is "" (default value of the constructor), a ValueError is raised.

    After running, the model described by mdl.input_prompt is converted and stored in mdl in the following way:
        mdl.variables:          A dict of all model variables, where the keys are strings
                                with variable names and the values are strings with mathematical definitions
        mdl.var_units:          Same keys as mdl.variables, values are strings describing the units
        mdl.var_descriptions:   Same keys as mdl.variables, values are strings in human language describing the variables
        mdl.var_refs:           Same keys as mdl.variables, values are strings describing the references
                                (publication, etc.) where the definition came from
        mdl.variables_formatted:Same keys as mdl.variables, values are strings with mathematical definitions,
                                formatted based on values in mdl.options, ready to be solved
        mdl.dependencies:       Same keys as mdl.variables, values are sets such that for each key, the value is
                                a set with names of all variables, that the key depends on in order to be calculated
        mdl.solving_order:      List of all variables of mdl, organized in an order that allows for solving
                                (no variable appears before all its dependencies)

        mdl.consts:             A subset of mdl.variables, containing only model constants
        mdl.inputs:             A subset of mdl.variables, containing only model inputs
        mdl.functions:          A subset of mdl.variables, containing only model functions
        mdl.aux:                A subset of mdl.variables, containing only model auxiliary states
        mdl.states:             A subset of mdl.variables, containing only model states
        mdl.init:               A dictionary with the same keys as mdl.states, with values holding the initial values
        mdl.input_data:         A pandas DataFrame holding data for the variables in mdl.inputs
                                If no input data is given, this DataFrame has a single column, "Time", with 2 rows,
                                representing mdl.options["t_start"] and mdl.options["t_end"]
        mdl.full_sol:           A pandas DataFrame with a "Time" column, and a column for each model variable,
                                except constants and functions. At this moment it is an "empty" solution, which will
                                get populated after model solving

    :param mdl: A GreenLightInternal object, with mdl.input_prompt defined (e.g., by a constructor)
    :return: None
    :raises: A ValueError if mdl.input_prompt is an empty string
    """
    if not mdl.input_prompt:
        raise ValueError("No input prompt provided: attribute input_prompt for GreenLightInternal object is empty")

    # Convert input_prompt to a flattened list of only dicts and strings
    input_prompt = _utils.flatten_input(mdl.input_prompt)

    # Read input_prompt, one argument at a time
    print("\n")
    for input_arg in input_prompt:
        directory = ""

        # Check if input_arg is a file name and append a directory to it if needed
        if isinstance(input_arg, str):
            mdl.add_to_log(f"Loading model from {input_arg}", warn=False, to_print=True)
            _, extension = os.path.splitext(input_arg)
            if extension:  # input_arg is a file name
                directory, file_name = os.path.split(input_arg)

                # If no new directory was found, use the base path
                if directory == "":
                    directory = mdl.base_path
                else:  # Look at the directory relative to base_path
                    directory = os.path.join(mdl.base_path, directory)

                _load_input_arg(mdl, file_name, directory)
            else:  # input_arg is not a file name
                _load_input_arg(mdl, input_arg, directory)

        elif isinstance(input_arg, dict):
            _load_input_arg(mdl, input_arg)

        else:
            raise ValueError("Input argument %r is not a string or a dict" % (input_arg,))

    # After loading all variables into mdl, format them according to the chosen options
    mdl.variables_formatted, mdl.dependencies, mdl.solving_order = _parse_model.format_expressions(
        mdl.variables,
        mdl.states.keys(),
        mdl.functions,
        mdl.options["formatting_mode"],
        mdl.options["expand_functions"].strip().lower() == "true",
        mdl.options["expand_variables"].strip().lower() == "true",
    )

    # If no input data was loaded, set the input_data attribute as a DataFrame with a single column, "Time",
    # with two rows: the t_start and the t_end options
    if mdl.input_data.empty:
        mdl.input_data["Time"] = [float(mdl.options["t_start"]), float(mdl.options["t_end"])]

    # Set up the format for the model solution:
    # A DataFrame with a "Time" column and all model variables except constants and functions
    full_sol_cols = list(mdl.variables.keys())
    for key in (mdl.functions | mdl.consts).keys():
        if key in full_sol_cols:
            full_sol_cols.remove(key)
    if "Time" not in full_sol_cols:
        full_sol_cols.extend(["Time"])
    mdl.full_sol = pd.DataFrame(columns=full_sol_cols)

    # List of strings representing the defined dynamic model written as Python commands
    if mdl.options["expand_variables"].strip().lower() == "true":
        mdl.commands = _utils.expressions_to_dy_str(
            {key: mdl.variables_formatted[key] for key in mdl.states}, mdl.inputs.keys()
        )
    else:
        mdl.commands = _utils.expressions_to_dy_str(
            {key: mdl.variables_formatted[key] for key in mdl.states},
            mdl.inputs.keys(),
            {key: mdl.variables_formatted[key] for key in mdl.solving_order if key not in mdl.inputs.keys()},
            [key for key in mdl.solving_order if key not in mdl.inputs.keys()],
        )


def _load_input_arg(mdl: GreenLightInternal, input_arg: str | dict, input_dir: str = "") -> None:
    """
    Load and parse a single input argument onto a GreenLightInternal object. The input argument either describes a model
    component in a JSON (or dict) type format or by a str which is a file path of a JSON or CSV file to be loaded.
    Alternatively, the input argument contains a "processing_order" node, with a list of other model components
    to be loaded according to a specific processing order.

    The following attributes of mdl are modified:
        mdl.variables: Updated with the definitions of any new or modified variables
        mdl.var_units: Updated with the units of any new or modified variables
        mdl.var_description: Updated with the descriptions of any new or modified variables
        mdl.var_refs: Updated with the references of any new or modified variables

        mdl.inputs: Updated with the names of any new input variables
        mdl.input_data: Updated to include any added input data

        mdl.consts: Updated with the definitions of any new or modified constants
        mdl.functions: Updated with the definitions of any new or modified functions
        mdl.aux: Updated with the definitions of any new or modified auxiliary states
        mdl.states: Updated with the definitions of any new or modified state variables
        mdl.init: Updated with the definitions of any new or modified initial values for the state variables

        mdl.options: Updated to include modifications to options

    :param mdl: A GreenLightInternal object to be modified
    :param input_arg: May be one of the following:
        A str containing the location of a JSON or CSV file to be loaded (in this case, is_file_path should be True)
        A str describing a model component in JSON format. Example: "{"var1": {"type": "const", "definition": "6"}}"
        A dict describing a model component. Example: {"var1": {"type": "const", "definition": "6"}}
        input_arg (or the JSON file at the location of input_arg) may contain a key "processing_order" which has a value
        which is a list: {"processing_order": [input_arg_1, input_arg_2, ...]}.
        In this case, only the node for "processing_order" is considered. The function then processes
        each of the values in the list iteratively, using each value of the list as input_arg.
    :param input_dir:
        If input_arg is a location of a file, input_dir is a reference directory, i.e., the file should
            be located in os.path.join(input_dir, input_arg).
        If input_arg is not a location of a file, this should be ""
    :return: None
    :raises: ValueError if the input argument is not a str or dict
    """
    loaded_dict = {}
    if input_dir:  # input_arg is a str which is a file path
        _, extension = os.path.splitext(input_arg)
        if extension == ".csv":
            # Check if the CSV file is part of greenlight's packaged resources
            input_dir_path = PurePath(os.path.abspath(input_dir))
            resources_path = PurePath(resources.files("greenlight"))
            is_resource = input_dir_path == resources_path or resources_path in input_dir_path.parents

            if is_resource:
                resource_file = resources.files("greenlight").joinpath(
                    Path(
                        os.path.join(
                            os.path.relpath(os.path.abspath(input_dir), resources.files("greenlight")), input_arg
                        )
                    )
                )
                try:
                    with resource_file.open("rb") as csv_file:
                        loaded_df = pd.read_csv(csv_file, dtype=str, encoding="utf-8")
                except UnicodeDecodeError:  # The file was probably written in Excel but contains Unicode
                    with resource_file.open("rb") as csv_file:
                        loaded_df = pd.read_csv(csv_file, dtype=str, encoding="Windows-1252")
            else:  # The file is not a package resource
                try:
                    loaded_df = pd.read_csv(os.path.join(input_dir, input_arg), dtype=str, encoding="utf-8")
                except UnicodeDecodeError:  # The file was probably written in Excel but contains Unicode
                    loaded_df = pd.read_csv(os.path.join(input_dir, input_arg), dtype=str, encoding="Windows-1252")

            _add_input_data(mdl, loaded_df, input_arg)

        elif extension == ".json":
            # Check if the JSON file is part of greenlight's packaged resources
            input_dir_path = PurePath(os.path.abspath(input_dir))
            resources_path = PurePath(resources.files("greenlight"))
            is_resource = input_dir_path == resources_path or resources_path in input_dir_path.parents

            if is_resource:
                resource_file = resources.files("greenlight").joinpath(
                    Path(
                        os.path.join(
                            os.path.relpath(os.path.abspath(input_dir), resources.files("greenlight")), input_arg
                        )
                    )
                )
                with resource_file.open("r", encoding="utf-8") as json_file:
                    loaded_dict = json.load(json_file, object_pairs_hook=_utils.json_raise_on_duplicates)
            else:
                with open(os.path.join(input_dir, input_arg), "r", encoding="utf-8") as json_file:
                    #  Load the JSON as a dict
                    loaded_dict = json.load(json_file, object_pairs_hook=_utils.json_raise_on_duplicates)

    elif isinstance(input_arg, str):  # input_arg is a str describing model structure in JSON format
        loaded_dict = json.loads(input_arg, object_pairs_hook=_utils.json_raise_on_duplicates)

    elif isinstance(input_arg, dict):  # input_arg is a dict describing model structure
        loaded_dict = _utils.json_raise_on_duplicates(input_arg.items())

    else:
        raise ValueError("Input argument is not a str or dict. Input argument: %r" % input_arg)

    if loaded_dict and "processing_order" in loaded_dict:  # The loaded dict has a "processing_order" node,
        # which should contain a list of other files/sub-models.
        # In this case only the "processing_order" node is taken into account
        for line in loaded_dict["processing_order"]:
            if isinstance(line, dict):
                _add_variables(mdl, line, input_arg)
            elif isinstance(line, str):
                directory, file_name = os.path.split(line)

                # If the file_name in "processing_order" was only a file name (input_dir == ""),
                # use the directory in line as a base_path. Otherwise, consider the directory in line as relative to
                # the one of the file that contained "processing_order"
                if input_dir:
                    directory = os.path.join(input_dir, directory)
                    line = file_name
                _, extension = os.path.splitext(line)

                if extension != "":  # The line describes a file
                    _load_input_arg(mdl, line, directory)
                else:  # The line describes a dict
                    _add_variables(mdl, line, input_arg)
            else:
                raise ValueError("Input argument is not a str or dict. Input argument: %r" % input_arg)

    else:
        _add_variables(mdl, loaded_dict, input_arg)


def _add_variables(mdl: GreenLightInternal, model_component: dict, model_component_name: str) -> None:
    """
    Add model variables from a dict (typically loaded from a JSON file) into a GreenLightInternal object.
    The following attributes of mdl are modified:
        mdl.variables: Updated with the definitions of any new or modified variables
        mdl.var_units: Updated with the units of any new or modified variables
        mdl.var_description: Updated with the descriptions of any new or modified variables
        mdl.var_refs: Updated with the references of any new or modified variables

        mdl.consts: Updated with the definitions of any new or modified constants
        mdl.functions: Updated with the definitions of any new or modified functions
        mdl.aux: Updated with the definitions of any new or modified auxiliary states
        mdl.states: Updated with the definitions of any new or modified state variables
        mdl.init: Updated with the definitions of any new or modified initial values for the state variables

        mdl.options: Updated to include modifications to options

    :param mdl: A GreenLightInternal object to which the model data will be loaded
    :param model_component: A nested dict containing the model definition.
        This is typically taken from a JSON file (typically with filename model_component_name)
        and converted to a nested dict using json._load
        See docs/model_format.md for information on how the dict (and the JSON file defining it) should be structured
    :param model_component_name: The name of the file where model_component was loaded from. This is used to provide
        useful output in case the given model component overrides previously loaded model components
    :return: None
    :rtype: None
    :raises: ValueError raised by parse_model.extract_variables if circular dependencies are found.
    """
    issue_warnings = mdl.options["warn_loading"].strip().lower() == "true"

    try:
        logger = logging.getLogger(__name__)
        new_variables = _parse_model.extract_variables(model_component, extracted_type="all")
    except ValueError as err:
        logger.error(
            "Error in %r: %r"
            % (
                model_component_name,
                err,
            )
        )
        raise

    # new_variables is a dict with the following format:
    # {"definition": defs_dict, "unit": units_dict, "description": desc_dict, "reference": refs_dict}
    # Each of these dicts have the same keys, which are the names of the new variables to add.

    # Add all variables, add a log record if any variable is overwritten
    for key in new_variables["definition"].keys():  # These are also the keys of unit, description, reference
        for update_type in ["definition", "unit", "description", "reference"]:
            # Determine if a replacement should occur
            if _utils.is_replacement(mdl, new_variables, key, update_type):
                if update_type == "definition":
                    old_value = mdl.variables[key]
                elif update_type == "unit":
                    old_value = mdl.var_units[key]
                elif update_type == "description":
                    old_value = mdl.var_descriptions[key]
                elif update_type == "reference":
                    old_value = mdl.var_refs[key]

                # Add to log information about the replacement
                mdl.add_to_log(
                    f"\nReplaced variable {key} with {update_type} from {model_component_name}.\n"
                    + f"Old {update_type}: {old_value}\nNew {update_type}: {new_variables[update_type][key]}",
                    warn=issue_warnings,
                )

            # Determine if an update should occur - this may be true even if it is not a replacement
            # (e.g., a new value is added, that is not replacing an existing one)
            if _utils.is_update_to_perform(mdl, new_variables, key, update_type):
                # Perform the update
                if update_type == "definition":
                    mdl.variables[key] = new_variables[update_type][key]
                elif update_type == "unit":
                    mdl.var_units[key] = new_variables[update_type][key]
                elif update_type == "description":
                    mdl.var_descriptions[key] = new_variables[update_type][key]
                elif update_type == "reference":
                    mdl.var_refs[key] = new_variables[update_type][key]

    # Get options
    options = _parse_model.extract_options(model_component)

    # Add all options to mdl.options
    # issue a warning before overwriting previous options
    for key, value in options.items():
        if key in mdl.options and value != mdl.options[key]:
            mdl.add_to_log(
                f"\nReplaced option {key} by definition from {model_component_name}.\n"
                + f"Old definition: {mdl.options[key]}\nNew definition: {value}",
                warn=issue_warnings,
            )

        mdl.options[key] = value

    # Add constants to the dict of constants
    new_consts = _parse_model.extract_variables(model_component, extracted_type="const")
    mdl.consts.update({key: mdl.variables[key] for key in new_consts["definition"]})

    # Add functions to the dict of functions
    new_functions = _parse_model.extract_variables(model_component, extracted_type="function")
    mdl.functions.update({key: mdl.variables[key] for key in new_functions["definition"]})

    # Add auxiliary states to the dict of aux states
    new_aux = _parse_model.extract_variables(model_component, extracted_type="aux")
    mdl.aux.update({key: mdl.variables[key] for key in new_aux["definition"]})

    # Add states to the dict of states
    new_states = _parse_model.extract_variables(model_component, extracted_type="state")
    mdl.states.update({key: mdl.variables[key] for key in new_states["definition"]})

    # Inputs loaded from dicts or JSONs are considered aux, unless data is provided for them
    new_inputs = _parse_model.extract_variables(model_component, extracted_type="input")
    mdl.aux.update({key: mdl.variables[key] for key in new_inputs["definition"]})

    # Add initial values to the dict of initial values
    new_init = _parse_model.extract_variables(model_component, extracted_type="initial value")
    mdl.init.update(new_init["definition"])


def _add_input_data(mdl: GreenLightInternal, input_df: pd.DataFrame, input_df_name: str) -> None:
    """
    Add input variables to a GreenLightInternal object, using data from a pandas DataFrame (typically loaded from a CSV file).
    The following attributes of mdl are modified:
        mdl.variables: Each column name of input_df is added to the dict, with the column name as both key and value.
            If the column name already existed in mdl.variables, its definition is updated so that it is equal to the
            variable name.
            This means that the variable will no longer be computed. Instead, the input data will be used.
        mdl.states: If a column name existed as a name of a state variable, this variable is removed from mdl.states.
            This variable will no longer be computed as a state. Instead, the input data will be used.
        mdl.inputs: Each column name of input_df is added to the dict, with the column name as both key and value.
        mdl.var_units: For the added variables, if a description of a unit is found it is added,
            replacing any previous value.
        mdl.var_description: For the added variables, if a description of the variable is found it is added,
            replacing any previous value.
        mdl.input_data: Updated to include the data in input_df. If a variable already existed in mdl.input_data,
            it is replaced. If mdl.input_data was not empty before calling this function, the Time values of
            mdl.input_data and those of input_df are combined by interpolation so that mdl.input_data contains
            the same Time values for all variables

    :param mdl: A GreenLightInternal object to which model data will be added
    :param input_df: A pandas DataFrame containing input data. Typically loaded from a CSV file with filename
        input_df_name. The columns of the DataFrame are used as  variables names. If the DataFrame contains
        non-numerical rows, the following assumptions are made:
            If there is one non-numerical row, it is assumed to describe the units of the variables
            If there are more than one non-numerical rows, it is assumed that the first row contains descriptions of
            the variables, and that the second describes the units of the variables
        The actual data will be loaded from the first row containing only numeric values.
    :param input_df_name: The name of the file where input_df was loaded from. This is used to provide useful logs in
        case the data overrides previously loaded model components.
    :return: None
    """

    issue_warnings = mdl.options["warn_loading"].strip().lower() == "true"

    # Find the first numeric row in input_df
    def is_numeric_row(row):
        # Convert each element to a number; return True if all are numeric, else False
        return row.apply(lambda x: pd.to_numeric(x, errors="coerce")).notna().all()

    first_num_row = len(input_df)
    for row_num in range(len(input_df)):
        if is_numeric_row(input_df.iloc[row_num]):
            first_num_row = row_num
            break

    def replace_attribute(attribute, row_index):
        if attribute == "unit":
            if column in mdl.var_units and mdl.var_units[column] != input_df.loc[row_index, column]:
                mdl.add_to_log(
                    f"Replaced unit for input variable {column}:\n"
                    f"Previous unit: {mdl.var_units[column]}\n"
                    f"New unit: {input_df.loc[row_index, column]}",
                    warn=issue_warnings,
                )
            mdl.var_units[column] = input_df.loc[row_index, column]
        elif attribute == "description":
            if column in mdl.var_descriptions and mdl.var_descriptions[column] != input_df.loc[row_index, column]:
                mdl.add_to_log(
                    f"Replaced description for input variable {column}: \n"
                    f"Previous description: {mdl.var_descriptions[column]}\n"
                    f"New description: {input_df.loc[row_index, column]}",
                    warn=issue_warnings,
                )
            mdl.var_descriptions[column] = input_df.loc[row_index, column]

    for column in input_df:
        if column in mdl.variables:
            mdl.add_to_log(f"\nReplaced variable {column} by input values from {input_df_name}.", warn=issue_warnings)
        if column in mdl.states:
            del mdl.states[column]  # Remove variable from states
        if column in mdl.aux:
            del mdl.aux[column]  # Remove variable from auxiliary states

        # Add variable to the list of variables (unless it is the time variable)
        if column.lower() != "time":
            mdl.variables[column] = column  # Add the variable to list of variables
            mdl.inputs[column] = column

        if first_num_row == 1:  # 2 header rows in the input CSV, assume the second row is units
            replace_attribute("unit", 0)
        elif first_num_row > 1:  # More than 2 header rows, assume the second is description and the third is units
            replace_attribute("description", 0)
            replace_attribute("unit", 1)

    numeric_input = input_df[first_num_row:]
    numeric_input = numeric_input.apply(pd.to_numeric, errors="coerce")
    numeric_input.reset_index(drop=True, inplace=True)

    if "Time" not in numeric_input:
        mdl.add_to_log(
            f"No Time column in input file {input_df_name}. The data will not be used for simulation",
            warn=issue_warnings,
        )

    if mdl.input_data.empty or "Time" not in mdl.input_data:
        # There's not any input data yet, or the existing data has no Time, it cannot be used, so just use the new data
        mdl.input_data = numeric_input
    elif "Time" in numeric_input:
        # Both the new and the old data have Time values, interpolate the new values based on the existing Time
        for col in numeric_input:
            if col != "Time":
                if col in mdl.input_data:
                    mdl.add_to_log(
                        f"\nReplaced existing input {col} by input values from {input_df_name}.", warn=issue_warnings
                    )
                if mdl.options["interpolation"] == "linear":
                    mdl.input_data[col] = np.interp(mdl.input_data["Time"], numeric_input["Time"], numeric_input[col])
                else:  # Default is "left"
                    rows = mdl.input_data["Time"].searchsorted(numeric_input["Time"])
                    rows = np.clip(rows, 0, mdl.input_data.shape[0] - 1)
                    mdl.input_data[col] = numeric_input[rows, col].reset_index(drop=True)
