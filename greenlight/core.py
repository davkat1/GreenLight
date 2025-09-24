"""
GreenLight/greenlight/core.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Define the GreenLight class - a public class for running GreenLight simulations. The class inherits from the internal
class GreenLightInternal, defined in _greenlight_internal. The reason for this separation is to allow the submodules of
greenlight to import the greenlight structure (GreenLightInternal), while GreenLight can import submodules,
without circular imports
"""

from typing import Dict, List, Union

from ._greenlight_internal import GreenLightInternal
from ._load import load_model
from ._save import save_sim
from ._solve import solve_model


class GreenLight(GreenLightInternal):
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

        options (dict[str, str]): A dictionary containing options related to model formatting and solving,
            see docs/simulation_options.md

    Methods:
        GreenLight(input_prompt: Union[str, Dict, List[Union[str, Dict]]] = "", output_path: str = "")
            Constructor for the GreenLight class
        load(self):
            Load the model structure (as defined according to input_prompt) onto a GreenLightInternal instance
        solve(self):
            Perform the simulation (i.e., solve the ODEs) as defined after using load()
        save(self):
            After running the model, save calculated values and any other logs to files, based on the location specified by output_path
        run(self):
            Load, solve, and save the model, as described above.

    Example usage:
        >>> from greenlight import GreenLight
        >>> mdl = GreenLight()
        >>> mdl.load()
        >>> mdl.solve()
        >>> mdl.save()

    Alternatively:
        >>> from greenlight import GreenLight
        >>> mdl = GreenLight()
        >>> mdl.run()

    The above 2 examples will run GreenLight with default settings - simulating a greenhouse as in Katzin (2021),
    for one day with default weather inputs.
    GreenLight may also be used to simulate any model provided in the GreenLight format, for example:
        >>> from greenlight import GreenLight
        >>> mdl = GreenLight(base_path="C:\\Models",input_prompt="my_model.json",output_path="out.csv")
        >>> mdl.run()

    See docs/using_greenlight.md for more information.
    """

    def __init__(
        self,
        base_path: str = "",
        input_prompt: Union[str, Dict, List[Union[str, Dict]]] = "",
        output_path: str = "",
        optional_prompt: Union[str, Dict, List[Union[str, Dict]]] = "",
    ):
        """
        Constructor for the GreenLight class. All attributes are set to default values, except the function arguments.

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
        super().__init__(base_path, input_prompt, output_path, optional_prompt)

    def load(self) -> None:
        """
        Load and parse a GreenLight model based on its input_prompt.
        input_prompt can be defined by the constructor of GreenLight, see greenlight.GreenLight().
        If the input_prompt is "" (default value of the constructor), a ValueError is raised.
        See greenlight._load for more information

        :return: None
        """
        load_model(self)

    def solve(self) -> None:
        """
        Solve a GreenLight model based on the model definitions and options set in it (typically using GreenLight.load())
        After running this function, the model variables are calculated and stored in the object.
        See greenlight._solve for more information

        :return: None
        """
        solve_model(self)

    def save(self) -> None:
        """
        Save a GreenLight simulation to files. It is assumed that the model was already loaded and solved,
        e.g., by GreenLight.load() and GreenLight.solver().
        See greenlight._save for more information

        :return: None
        """
        save_sim(self)

    def run(self) -> None:
        """
        Load, solve, and save a GreenLight model in one go. This performs the full simulation in order.

        :return: None
        """
        self.load()
        self.solve()
        self.save()
