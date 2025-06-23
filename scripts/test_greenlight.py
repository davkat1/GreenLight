import os
import sys

from greenlight import GreenLight

"""Set up directories"""
if "__file__" in locals():  # Running this from script
    project_dir = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
else:
    project_dir = os.getcwd()  # Most likely the active directory is the project directory
sys.path.append(project_dir)

base_path = os.path.join(project_dir, "models")
output_dir = os.path.join("van_henten_2003", "output")
model = [
    os.path.join("van_henten_2003", "definition", "main_evh2003_setpoint_control.json"),
]

# Define a model with no inputs
# model = [
#     os.path.join("van_henten_2003", "definition", "greenhouse_evh2003.json"),
#     os.path.join("van_henten_2003", "definition", "control_setpoints.json")
#     ]

"""Numbers of days to simulate"""
n_days = 10

options = {
    "options": {
        "t_end": str(n_days * 24 * 3600),
        "solving_method": "solve_ivp",
        "formatting_mode": "math",
        "expand_variables": "False",
        "expand_functions": "True",
    }
}


"""Run simulations"""
output_file_name = "greenlight_test.csv"

modifications = []

input_arg = [model, options, modifications]
output_arg = os.path.join(output_dir, output_file_name)
test_model = GreenLight(base_path=base_path, input_prompt=input_arg, output_path=output_arg)
test_model.run()
