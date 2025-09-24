"""
GreenLight/greenlight/_greenlight_internal.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Define the GreenLightInternal class - a class of dynamic models constructed from input strings, dicts, and JSON files
This class is used internally within the package, whereas GreenLight, which inherits from it,
is the public class for external use. The reason for this separation is to allow the submodules of greenlight to
import the greenlight structure (GreenLightInternal), while GreenLight can import submodules, without circular imports
"""

import datetime
import importlib
import importlib.resources as resources
import os
import platform
import sys
import warnings
from pathlib import Path, PurePath
from typing import Dict, List, Union

import pandas as pd


class GreenLightInternal:
    """
    Represents a dynamic model based on input definitions and data. The model is defined by ordinary differential
    equations (ODEs). The model can be simulated by solving the ODEs. These results can be saved onto a file.

    Attributes:
         base_path (str): A file path used as a basis, all other file paths (files used in input, output path), are
            considered relative to this path. For example, output file is saved to os.path.join(base_path, output_path)
         input_prompt (str): The input prompt given to the model, containing model definitions and locations
            (file paths) of model definitions and inputs
         output_path (str): The file path where the output should be saved
         log (str): A log of warnings and other messages created during the loading and running of the model

         variables (dict[str, str]): All the model variables (with their names as keys)
            and their mathematical definitions (in the corresponding values)
        var_units (dict[str, str]): The units of all variables, as provided in the definitions
        var_descriptions (dict[str, str]): The descriptions of the variables, as provided in the definitions
        var_refs (dict[str, str]): The references (publication, etc.) of all variables, as provided in the definitions
        variables_formatted (dict[str, str]): The model variables after being loaded and formatted
        dependencies (dict[str, str]): For each variable, a list of the variables that this variable depends on
        solving_order (list): All model variables, ordered in a way they can be solved sequentially
        commands (list[str]): Representation of the defined dynamic model as Python commands

        consts (dict[str, str]): A subset of variables, containing the model constants
        inputs (dict[str, str]): A subset of variables, containing the model inputs
        functions (dict[str, str]): A subset of variables, containing functions defined in the model
        aux (dict[str, str]): A subset of variables, containing model auxiliary states
        states (dict[str, str]): A subset of variables, containing the model states
        init (dict[str, str]): A dict with the same keys sa states, and with values containing the initial values
        input_data (pandas.DataFrame):  Input data provided to the model for each variable in inputs

        start_time (datetime.datetime): The start time in the simulated model run
        states_sol (numpy.array): Solution of the states trajectories
        full_sol (pandas.DataFrame): Time trajectories of all model variables, after solving

        options (dict[str, str]): A dictionary containing options related to model formatting and solving
    """

    def __init__(
        self,
        base_path: str = "",
        input_prompt: Union[str, Dict, List[Union[str, Dict]]] = "",
        output_path: str = "",
        optional_prompt: Union[str, Dict, List[Union[str, Dict]]] = "",
    ):
        """
        Constructor for the GreenLightInternal class. All attributes are set to default values, except the function arguments.

        :param base_path: File path used as a basis for input and output file locations.
            Files in input_prompt and output_path are assumed to be relative to base_path, i.e., for saving output,
            os.path.join(base_path, output_path), is used. Similarly for files used for input
            If the default value is given (""), the base_path will be set to the location of the models in
            greenlight's package resources: PurePath(resources.files("greenlight") / "models")
        :param input_prompt: This can be a string, dict, or a list of strings and dicts.
            strings can be file names, pointing to either .json files (model descriptions) or .csv files (input data)
            The full file path is needed for the first file, after which only the file name is sufficient,
                e.g., [r"C:\files\file1.json", "file2.json", "file3.csv"].
            strings can also be JSON-like or dict-like expressions,
                e.g., f'''{{"options": {{"t_end": "{n_days * 24 * 3600}"}}}}'''
            dicts can be used instead of .json files or JSON-like expressions,
                e.g., {"options": {"t_end": n_days * 24 * 3600}}
            dicts, JSONs, etc. can also contain references to other files, see docs/modifying_and_combining_models.md
            If the default value is given (""), the input_prompt used will be the location of the Katzin 2021 model
            in greenlight's package resources, and the location of the weather dataset used for testing:
                [str(PurePath(resources.files("greenlight") / r"models/katzin_2021/definition/main_katzin_2021.json")),
                    str(PurePath(resources.files(
                    "greenlight") / r"models/katzin_2021/input_data/test_data/Bleiswijk_from_20091020.csv"))]
        :param output_path: Location of where the output file should be saved to.
                            If the default value is given (""), the file will be placed in
                            PurePath(Path.cwd() / r"output/greenlight_output_<current_time>.csv")
        :param optional_prompt: Any additional input that will be parsed together with input_prompt.
            Included here so that input_prompt can default to the default model, but users can still make modifications
            using additional_input
        """
        if not base_path:  # Default to the package's models directory
            base_path = str(PurePath(resources.files("greenlight") / "models"))
        if not input_prompt:  # Default to the Katzin 2021 in the package's models directory
            input_prompt = [
                str(PurePath(resources.files("greenlight") / r"models/katzin_2021/definition/main_katzin_2021.json")),
                str(
                    PurePath(
                        resources.files("greenlight")
                        / r"models/katzin_2021/input_data/test_data/Bleiswijk_from_20091020.csv"
                    )
                ),
            ]
        if not output_path:  # Default to cwd/output
            output_dir = Path.cwd() / "output"
            file_name = "greenlight_output_" + datetime.datetime.now().strftime("%Y%m%d_%H%M") + ".csv"
            output_path = str(PurePath(output_dir / file_name))
            output_dir.mkdir(parents=True, exist_ok=True)

        self.base_path = base_path

        # Combine input_prompt and additional_input. input_prompt defaults to the default model,
        # but additional_input allows to make modifications to the default
        self.input_prompt = [input_prompt, optional_prompt]
        self.output_path = output_path

        # Add to object log some system information
        self.log = (
            f"GreenLight simulation running greenlight version {importlib.metadata.version('greenlight')}\n"
            f"Python version: {platform.python_version()}\n"
            f"Platform: {platform.system()}\n"
            f"Platform release: {platform.release()}\n"
            f"Architecture: {platform.architecture()[0]}\n"
            f"Machine: {platform.machine()}\n"
            f"Script: {os.path.basename(sys.argv[0]) if len(sys.argv) > 0 else None}\n"
            f"Object created (ISO format): {datetime.datetime.now().isoformat()}\n\n"
        )

        self.variables = {}
        self.var_units = {}
        self.var_descriptions = {}
        self.var_refs = {}
        self.variables_formatted = {}
        self.dependencies = {}
        self.solving_order = []
        self.commands = []

        self.consts = {}
        self.inputs = {}
        self.functions = {}
        self.aux = {}
        self.states = {}
        self.init = {}
        self.input_data = pd.DataFrame()

        self.start_time = None

        self.states_sol = []
        self.full_sol = pd.DataFrame()

        #  Options for loading and simulating. See docs/simulation_options.md
        self.options = {
            "t_start": "0",
            "t_end": "86400",  # Default is one day = 86400 seconds
            "formatting_mode": "numpy",  # "numpy", "math", or "numexpr"
            "expand_variables": "False",  # If "True", mathematical expressions describing model variables
            # will be expanded to be described using only built-in expressions, inputs, and model states
            "expand_functions": "True",  # If "True", model functions will be expanded and replaced
            # in variable definitions
            "solving_method": "solve_ivp_from_str",  # "solve_ivp" or "solve_ivp_from_str"
            "interpolation": "linear",  # "left" or "linear"
            "solver": "BDF",  # Depends on the solving method, typically one of the methods of solve_ivp, see:
            # https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html
            "first_step": "None",  # Passed as an argument to the ODE solver
            "max_step": "3600",  # Default is 1 hour = 3600 seconds
            "atol": "1e-3",  # Passed as an argument to the ODE solver
            "rtol": "1e-6",  # Passed as an argument to the ODE solver
            "output_step": "3600",  # Default is 1 hour = 3600 seconds
            "t_eval": "None",  # If "None", t_eval is passed as None to the ODE solver
            "clip_large_nums": "True",  # If "True", clip values to [-1e38, 1e38],
            # roughly the limit of a 32-bit floating point
            "nans_to_zeros": "True",  # If "True", whenever NaN is encountered it is replaced by 0
            "warn_loading": "False",  # If "True", warnings are issued during loading
            "warn_runtime": "False",  # If "True", warnings are issued during runtime
            "log_runtime_warnings": "True",  # If "True", runtime warnings are included in the simulation log
        }

    def add_to_log(self, log_text: str, warn: bool = True, to_print: bool = False) -> None:
        """
        Add a message to the simulation log of self.

        :param log_text: The text to add to the simulation log
        :param warn: If true, a warning is issued
        :param to_print: If true, the text is printed to the console
        :return: None
        """
        self.log = self.log + log_text + "\n"
        if warn:
            warnings.warn(log_text)
        if to_print:
            print(log_text)
