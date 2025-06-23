"""
greenlight/greenlight/_user_interface.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Sets up the GUI used by greenlight/greenlight/main.py
"""

import datetime
import os
import tkinter as tk
from tkinter import filedialog

from tkcalendar import DateEntry


class MainPrompt(tk.Tk):
    def __init__(self, models_dir=""):
        super().__init__()

        # Force the prompt to appear in front
        self.lift()
        self.attributes("-topmost", True)

        # Set the size and location of the prompt
        screen_width = self.winfo_screenwidth()
        screen_height = self.winfo_screenheight()
        width = screen_width // 2
        height = screen_height
        self.geometry(f"1200x1200+{screen_width // 2 - width // 2}+{screen_height // 2 - height // 2}")

        self.result = {}  # dict containing the result (input values) of running the interface

        self.title("Run a GreenLight simulation")

        default_base_path = os.path.abspath(models_dir)

        default_model_file = os.path.abspath(
            os.path.join(models_dir, "katzin_2021", "definition", "main_katzin_2021.json")
        )
        default_energy_plus_file = os.path.abspath(
            os.path.join(
                models_dir, "katzin_2021", "input_data", "energyPlus_original", "NLD_Amsterdam.062400_IWECEPW.csv"
            )
        )
        if os.path.isfile(default_energy_plus_file):
            default_input_data_file = default_energy_plus_file
        else:
            default_input_data_file = ""

        default_output_file = os.path.abspath(
            os.path.join(
                models_dir,
                "katzin_2021",
                "output",
                "greenlight_output_" + datetime.datetime.now().strftime("%Y%m%d_%H%M") + ".csv",
            )
        )

        self.base_path = tk.StringVar(value=default_base_path)
        self.model_file = tk.StringVar(value=default_model_file)
        self.input_data_file = tk.StringVar(value=default_input_data_file)

        self.start_date_picker = None
        self.end_date_picker = None

        self.modifications_box = None

        self.save_location = tk.StringVar(value=default_output_file)

        self.create_widgets()

    def create_widgets(self):
        # Title
        row = 0
        tk.Label(self, text="Run a greenlight simulation", font=("Helvetica", 16, "bold")).grid(
            row=row, column=0, columnspan=1, padx=5, pady=5
        )
        row += 1

        tk.Label(
            self,
            text="In order to run a simulation, the following choices must be made:",
            font=("Helvetica", 10),
            anchor="w",
        ).grid(row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5)
        row += 1

        # Explanation on base path
        tk.Label(self, text="Model base path", font=("Helvetica", 10, "bold"), anchor="w").grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        row += 1

        tk.Label(
            self,
            text=(
                "This is a location on the local machine that is used for logging purposes. "
                "When logging which files were read and written, they are logged relative to this path.\n"
                "Typically this is a project folder, that the input and output folder are located within it."
            ),
            font=("Helvetica", 10),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Choose base path
        self._file_row("Select base path:", self.base_path, row, "browse_dir")
        row += 1

        # Explanation on model definition file
        tk.Label(self, text="Model definition file", font=("Helvetica", 10, "bold"), anchor="w").grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        row += 1

        tk.Label(
            self,
            text=(
                'This is a JSON file, typically with a "processing_order" node, '
                "which defines the model structure. "
                "The current default defines a model as in Katzin 2021 (PhD thesis, Chapter 4).\n"
                "This represents a modern high-tech greenhouse with LED lamps."
            ),
            font=("Helvetica", 10),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Choose model definition file
        self._file_row("Select model definition file:", self.model_file, row, "browse_file")
        row += 1

        # Explanation on input data file
        tk.Label(self, text="Input data file", font=("Helvetica", 10, "bold"), anchor="w").grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        row += 1

        tk.Label(
            self,
            text=(
                "Input data can be added, for example weather data. "
                "In the default settings, this must be a CSV file in the same format as the weather files of EnergyPlus.\n"
                "You can get such files by downloading weather data in EPW format from https://energyplus.net/weather\n"
                'Then installing EnergyPlus (https://energyplus.net/downloads), and using the "Weather statistics and conversion tool" '
                "to convert the EPW to CSV.\n "
                "If no file is loaded, constant values for the weather inputs are used."
            ),
            font=("Helvetica", 10),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Choose input data file
        self._file_row("Select input data file:", self.input_data_file, row, "browse_file")
        row += 1

        # Explanation on time range
        tk.Label(self, text="Simulation date range", font=("Helvetica", 10, "bold"), anchor="w").grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        row += 1

        tk.Label(
            self,
            text=(
                "The chosen weather file will be formatted to describe a chosen growing season, "
                "according to the selected date range.\n"
                "Note that since EnergyPlus uses standardized years, the particular choice of year doesn't "
                "have an influence. Leap years will be ignored (February 29 will not be included)"
            ),
            font=("Helvetica", 10),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Start and End Dates
        default_start = datetime.date(2021, 9, 27)
        default_end = datetime.date(2022, 9, 12)

        tk.Label(self, text="Start Date:").grid(row=row, column=0, sticky="w", padx=5, pady=5)
        self.start_date_picker = DateEntry(
            self, width=50, year=default_start.year, month=default_start.month, day=default_start.day
        )
        self.start_date_picker.grid(row=row, column=1, padx=5, pady=5)
        row += 1

        tk.Label(self, text="End Date:").grid(row=row, column=0, sticky="w", padx=5, pady=5)
        self.end_date_picker = DateEntry(
            self, width=50, year=default_end.year, month=default_end.month, day=default_end.day
        )
        self.end_date_picker.grid(row=row, column=1, padx=5, pady=5)
        row += 1

        # Explanation on custom modifications
        tk.Label(self, text="Custom modifications", font=("Helvetica", 10, "bold"), anchor="w").grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        row += 1

        tk.Label(
            self,
            text=(
                "This text box allows to manually enter custom modifications that will be read by greenlight. "
                "For example, the text currently in the box will have the model load a file\n"
                "that changes the lamp parameters from LED to default HPS lamp values. "
                "Remove this text if you want to keep the default lamps values - LED lamps"
            ),
            font=("Helvetica", 10),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1
        self.modifications_box = tk.Text(self, width=40, height=4)
        self.modifications_box.grid(row=row, column=0, columnspan=3, padx=5, pady=(0, 10))
        self.modifications_box.insert("1.0", os.path.join("katzin_2021", "definition", "lamp_hps_katzin_2021.json"))
        row += 1

        # Output file
        tk.Label(self, text="Output file location", font=("Helvetica", 10, "bold"), anchor="w").grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        row += 1

        tk.Label(
            self,
            text=(
                "Choose where the simulation results should be stored. The simulation is stored in CSV format, "
                "some log files are also generated in the same folder as the chosen output"
            ),
            font=("Helvetica", 10),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Choose save location
        self._file_row("Save as:", self.save_location, row, "save_file")
        row += 1

        # Buttons
        tk.Label(self, text="Press OK to run the simulation", font=("Helvetica", 10, "bold"), anchor="w").grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        row += 1

        button_frame = tk.Frame(self)
        button_frame.grid(row=row, columnspan=2, pady=20)
        row = row + 1

        tk.Button(button_frame, text="OK", width=15, command=self.on_ok).grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        tk.Button(button_frame, text="Cancel", width=15, command=self.on_cancel).grid(
            row=row, column=1, sticky="w", columnspan=1, padx=5, pady=5
        )

    def _file_row(self, label, var, row, dialog_type="browse_file"):
        """
        File input label and button. dialog_type can be one of the following:
            "browse_file": browse for a file
            "save_file": save a file
            "browse_dir": browse for a directory
        """
        tk.Label(self, text=label).grid(row=row, column=0, sticky="w", padx=5, pady=5)
        tk.Entry(self, textvariable=var, width=30).grid(row=row, column=1, padx=5, pady=5)
        tk.Button(self, text="Browse...", command=lambda: self.browse_file(var, dialog_type)).grid(
            row=row, column=2, padx=5, pady=5
        )

    @staticmethod
    def browse_file(var, dialog_type="browse_file"):
        if dialog_type == "save_file":
            filename = filedialog.asksaveasfilename(
                initialdir=os.path.join(var.get(), ".."),
                defaultextension=".csv",
                filetypes=[("CSV files", "*.csv"), ("All files", "*.*")],
            )
        elif dialog_type == "browse_dir":
            filename = filedialog.askdirectory(initialdir=os.path.join(var.get(), ".."))
        else:
            filename = filedialog.askopenfilename(initialdir=os.path.join(var.get(), ".."))

        if filename:
            var.set(filename)

    def on_ok(self):
        self.result = {
            "base_path": os.path.abspath(self.base_path.get()),
            "model": os.path.abspath(self.model_file.get()),
            "input_data": os.path.abspath(self.input_data_file.get()),
            "start_date": self.start_date_picker.get_date(),
            "end_date": self.end_date_picker.get_date(),
            "mods": self.modifications_box.get("1.0", "end-1c"),
            "output_file": os.path.abspath(self.save_location.get()),
        }
        self.destroy()

    def on_cancel(self):
        self.destroy()
