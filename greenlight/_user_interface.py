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
        width = min(screen_width, 1200)
        height = min(screen_height, 1100)
        self.geometry(f"{width}x{height}+{screen_width // 2 - width // 2}+{screen_height // 2 - height // 2}")

        self.result = {}  # dict containing the result (input values) of running the interface

        self.title("Run a GreenLight simulation")

        default_base_path = ""
        default_model_file = ""
        default_input_data_file = ""
        output_path = "output"

        if not os.path.exists(output_path):  # If output_path doesn't exist, create it
            os.makedirs(output_path)

        # Set default output directory
        default_output_file = os.path.abspath(
            os.path.join(
                output_path,
                "greenlight_output_" + datetime.datetime.now().strftime("%Y%m%d_%H%M") + ".csv",
            )
        )

        self.base_path = tk.StringVar(value=default_base_path)
        self.model_file = tk.StringVar(value=default_model_file)
        self.input_data_file = tk.StringVar(value=default_input_data_file)

        self.start_date_picker = None
        self.end_date_picker = None

        self.sim_length = 3

        self.save_location = tk.StringVar(value=default_output_file)

        self.modifications_box = None

        # Create a scrollable Frame
        container = tk.Frame(self)
        container.pack(fill="both", expand=True)

        canvas = tk.Canvas(container)
        v_scrollbar = tk.Scrollbar(container, orient="vertical", command=canvas.yview)
        h_scrollbar = tk.Scrollbar(container, orient="horizontal", command=canvas.xview)

        self.scrollable_frame = tk.Frame(canvas)

        # Update scroll region when frame resizes
        self.scrollable_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))

        canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")

        # Connect scrollbars
        canvas.configure(yscrollcommand=v_scrollbar.set, xscrollcommand=h_scrollbar.set)

        # Layout
        canvas.pack(side="left", fill="both", expand=True)
        v_scrollbar.pack(side="right", fill="y")
        h_scrollbar.pack(side="bottom", fill="x")

        # Build widgets
        self.create_widgets()

        # Call the widget builder
        self.create_widgets()

    def create_widgets(self):
        text_font_size = 10  # Default is 10
        # Title
        row = 0
        tk.Label(self.scrollable_frame, text="Run a greenlight simulation", font=("Helvetica", 16, "bold")).grid(
            row=row, column=0, columnspan=1, padx=5, pady=5
        )
        row += 1

        # Explanation on input data file
        tk.Label(
            self.scrollable_frame, text="Input data file", font=("Helvetica", text_font_size, "bold"), anchor="w"
        ).grid(row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5)
        row += 1

        tk.Label(
            self.scrollable_frame,
            text=(
                "Input data can be added, for example weather data. "
                "If left blank, the default dataset will be used (Bleiswijk, the Netherlands, starting 20/10/2009).\n"
                "Alternatively (1), select a formatted CSV containing data according to the required format.\n"
                "Alternatively (2), use a CSV file from EnergyPlus. "
                "You can get such files by downloading weather data"
                "in EPW format from https://energyplus.net/weather,\n"
                "installing EnergyPlus (https://energyplus.net/downloads),"
                'and using the "Weather statistics and conversion tool" to convert the EPW to CSV.\n '
            ),
            font=("Helvetica", text_font_size),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Choose input data file
        self._file_row("Select input data file:", self.input_data_file, row, text_font_size, "browse_file")
        row += 1

        # Explanation on time range
        tk.Label(
            self.scrollable_frame, text="Simulation date range", font=("Helvetica", text_font_size, "bold"), anchor="w"
        ).grid(row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5)
        row += 1

        tk.Label(
            self.scrollable_frame,
            text=(
                "If using a CSV file from EnergyPlus, The chosen weather file will be formatted to describe "
                "a chosen growing season, according to the selected date range.\n"
                "If using formatted CSV input data (like in the default setting), "
                "the input data will always be read from the beginning of the data."
            ),
            font=("Helvetica", text_font_size),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Simulation length
        # Validation function (only numbers allowed)
        def validate_number(new_value):
            return new_value.isdigit() or new_value == ""

        vcmd = (self.register(validate_number), "%P")
        tk.Label(
            self.scrollable_frame,
            text="Simulation length (in days):",
            font=("Helvetica", text_font_size),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", padx=5, pady=5)
        self.sim_length = tk.Entry(self.scrollable_frame, width=3, validate="key", validatecommand=vcmd)
        self.sim_length.grid(row=row, column=1, padx=5, pady=5)
        self.sim_length.insert(0, 3)
        row += 1

        # Start date
        default_start = datetime.date(2009, 10, 19)

        tk.Label(
            self.scrollable_frame,
            text="Start Date\n(only used when loading unformatted EnergyPlus CSV files, otherwise,\n"
            "the simulation will start at the beginning of the input dataset):",
            font=("Helvetica", text_font_size),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", padx=5, pady=5)
        self.start_date_picker = DateEntry(
            self.scrollable_frame, width=30, year=default_start.year, month=default_start.month, day=default_start.day
        )
        self.start_date_picker.grid(row=row, column=1, padx=5, pady=5)
        row += 1

        # Choose save location
        self._file_row("Save as:", self.save_location, row, text_font_size, "save_file")
        row += 1

        # Advanced options
        tk.Label(self.scrollable_frame, text="Advanced options", font=("Helvetica", text_font_size + 4, "bold")).grid(
            row=row, column=0, columnspan=1, padx=5, pady=5
        )
        row += 1

        # Explanation on base path
        tk.Label(
            self.scrollable_frame, text="Model base path", font=("Helvetica", text_font_size, "bold"), anchor="w"
        ).grid(row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5)
        row += 1

        tk.Label(
            self.scrollable_frame,
            text=(
                "This is a location on the local machine that is used for logging purposes. "
                "When logging which files were read and written, they are logged relative to this path.\n"
                "Typically this is a project folder, that the input and output folder are located within it."
            ),
            font=("Helvetica", text_font_size),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Choose base path
        self._file_row("Select base path:", self.base_path, row, text_font_size, "browse_dir")
        row += 1

        # Explanation on model definition file
        tk.Label(
            self.scrollable_frame, text="Model definition file", font=("Helvetica", text_font_size, "bold"), anchor="w"
        ).grid(row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5)
        row += 1

        tk.Label(
            self.scrollable_frame,
            text=(
                'This is a JSON file, typically with a "processing_order" node, '
                "which defines the model structure. "
                "The current default defines a model as in Katzin 2021 (PhD thesis, Chapter 4).\n"
                "This represents a modern high-tech greenhouse with LED lamps."
            ),
            font=("Helvetica", text_font_size),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1

        # Choose model definition file
        self._file_row("Select model definition file:", self.model_file, row, text_font_size, "browse_file")
        row += 1

        # Explanation on custom modifications
        tk.Label(
            self.scrollable_frame, text="Custom modifications", font=("Helvetica", text_font_size, "bold"), anchor="w"
        ).grid(row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5)
        row += 1

        tk.Label(
            self.scrollable_frame,
            text=(
                "This text box allows to manually enter custom modifications that will be read by greenlight.\n"
                r'For example, the text "katzin_2021\definition\lamp_hps_katzin_2021" '
                "will instruct the model "
                "to search for a file in this location (relative to the base path),\n"
                "which changes the lamp parameters from LED to default HPS lamp values. "
            ),
            font=("Helvetica", text_font_size),
            anchor="w",
            justify="left",
        ).grid(row=row, column=0, sticky="w", columnspan=2, padx=5, pady=5)
        row += 1
        self.modifications_box = tk.Text(self.scrollable_frame, width=40, height=4)
        self.modifications_box.grid(row=row, column=0, columnspan=3, padx=5, pady=(0, 10))
        row += 1

        # Run subtitle
        tk.Label(self.scrollable_frame, text="Run the simulation", font=("Helvetica", text_font_size + 4, "bold")).grid(
            row=row, column=0, columnspan=1, padx=5, pady=5
        )
        row += 1

        # Buttons
        tk.Label(
            self.scrollable_frame,
            text="Press OK to run the simulation",
            font=("Helvetica", text_font_size, "bold"),
            anchor="w",
        ).grid(row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5)
        row += 1

        button_frame = tk.Frame(self.scrollable_frame)
        button_frame.grid(row=row, columnspan=2, pady=20)
        row = row + 1

        tk.Button(button_frame, text="OK", width=15, command=self.on_ok).grid(
            row=row, column=0, sticky="w", columnspan=1, padx=5, pady=5
        )
        tk.Button(button_frame, text="Cancel", width=15, command=self.on_cancel).grid(
            row=row, column=1, sticky="w", columnspan=1, padx=5, pady=5
        )

    def _file_row(self, label, var, row, text_font_size=10, dialog_type="browse_file"):
        """
        File input label and button. dialog_type can be one of the following:
            "browse_file": browse for a file
            "save_file": save a file
            "browse_dir": browse for a directory
        """
        tk.Label(
            self.scrollable_frame, text=label, font=("Helvetica", text_font_size), anchor="w", justify="left"
        ).grid(row=row, column=0, sticky="w", padx=5, pady=5)
        tk.Entry(self.scrollable_frame, textvariable=var, width=50).grid(row=row, column=1, padx=5, pady=5)
        tk.Button(self.scrollable_frame, text="Browse...", command=lambda: self.browse_file(var, dialog_type)).grid(
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
        def abspath_or_blank(var):  # Return "" if var is empty, otherwise return os.path.abspath(var)
            return os.path.abspath(var) if var else ""

        self.result = {
            "input_data": abspath_or_blank(self.input_data_file.get()),
            "sim_length": self.sim_length.get(),
            "start_date": self.start_date_picker.get_date(),
            "output_file": abspath_or_blank(self.save_location.get()),
            "base_path": abspath_or_blank(self.base_path.get()),
            "model": abspath_or_blank(self.model_file.get()),
            "custom_mods": self.modifications_box.get("1.0", "end-1c"),
        }
        self.destroy()

    def on_cancel(self):
        self.destroy()
