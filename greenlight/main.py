"""
GreenLight/greenlight/main.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

First point of entry to the GreenLight package. Opens a GUI dialog box which allows to simply run a standard simulation.
In order to run meaningful simulations, input data must first be acquired. See docs/input_data.md

Next, for information on running more elaborate simulations, see docs.
"""

import os

from . import GreenLight, convert_energy_plus
from ._user_interface import MainPrompt


def main():
    # Open a UI interface and collect inputs from user
    file_dir = os.path.dirname(os.path.abspath(__file__))
    models_dir = os.path.join(file_dir, "..", "models")
    prompt = MainPrompt(models_dir)
    prompt.mainloop()

    if prompt.result:

        # Set up the required input_prompt for GreenLight
        base_path = prompt.result["base_path"]

        sim_length = (prompt.result["end_date"] - prompt.result["start_date"]).total_seconds()

        model = os.path.relpath(prompt.result["model"], base_path)

        mods = []
        if prompt.result["input_data"].endswith(".csv"):
            # An input data file was chosen, use it with the input dates to create a weather input file
            output_path, _ = os.path.splitext(prompt.result["output_file"])
            output_dir, output_file = os.path.split(prompt.result["output_file"])
            input_data_path = os.path.join(output_dir, "..", "input_data")
            filename, _ = os.path.splitext(output_file)
            formatted_weather_file = os.path.abspath(os.path.join(input_data_path, filename + "_formatted_weather.csv"))
            weather_path = convert_energy_plus(
                prompt.result["input_data"],
                formatted_weather_file,
                prompt.result["start_date"],
                prompt.result["end_date"],
                output_format="katzin2021",
            )
            mods = [os.path.relpath(weather_path, base_path)]

        mods.append({"options": {"t_end": sim_length}})
        mods.append(prompt.result["mods"])

        output = os.path.relpath(prompt.result["output_file"], base_path)

        # Create the model instance
        mdl = GreenLight(base_path=base_path, input_prompt=[model, mods], output_path=output)

        # Load, solve, and save. Note: these 3 lines can be replaced by mdl.run()
        mdl.load()
        mdl.solve()
        mdl.save()


if __name__ == "__main__":
    main()
