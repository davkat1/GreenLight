#!/bin/bash
set -e

echo "Setting up developer environment..."

# Install Miniconda if not already installed
if ! command -v conda &> /dev/null; then
  echo "Miniconda not found. Installing Miniconda..."
  wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
  bash miniconda.sh -b -p $HOME/miniconda
  export PATH="$HOME/miniconda/bin:$PATH"
  rm miniconda.sh
fi

# Create virtual environment if not exists
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate

# Upgrade pip and install dependencies
pip install --upgrade pip
if [ -f requirements_dev.txt ]; then
  pip install -r requirements_dev.txt
fi
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi
pip install -e .

# Create a conda environment
conda create -y --name greenlight python=3.10

# Activate the conda environment
eval "$(conda shell.bash hook)"
conda activate greenlight

echo "Developer environment is ready."
echo "To activate, run: source .venv/bin/activate"
# Install pre-commit hooks
pre-commit install
source .venv/bin/activate
echo " starting tests...."
#python3 scripts/epw_to_csv.py test_data/JPN_Tokyo.Hyakuri.477150_IWEC.epw models/katzin_2021/input_data/energyPlus_original/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv
#diff --suppress-common-lines models/katzin_2021/input_data/energyPlus_original/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv test_data/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv
cp test_data/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv models/katzin_2021/input_data/energyPlus_original/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv
python3 scripts/katzin_2021/katzin_2021_format_input_data.py
python3 scripts/greenlight_example.py
echo "Example script executed. You can now start developing with Greenlight."

