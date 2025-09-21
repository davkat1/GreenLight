#!/bin/bash
#Copyright (c) 2025 Shanaka Prageeth, Keio University, Japan
#SPDX-License-Identifier: BSD-3-Clause-Clear
set -e
DEBIAN_FRONTEND=noninteractive
PROGRAM_NAME="$(basename $0)"
BASEDIR=$(dirname $(realpath "$0"))
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
mkdir -p $BASEDIR/models/katzin_2021/input_data/energyPlus_original/
cp $BASEDIR/ci_test_data/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv $BASEDIR/models/katzin_2021/input_data/energyPlus_original/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv
python3 $BASEDIR/scripts/katzin_2021/katzin_2021_format_input_data.py
python3 $BASEDIR/scripts/greenlight_example.py
echo "=========================================================="
echo "Executing greenlight.main_cli with example parameters..."
echo "=========================================================="
python -m greenlight.main_cli \
  --base_path $BASEDIR/models \
  --model_file $BASEDIR/models/katzin_2021/definition/main_katzin_2021.json \
  --output_file $BASEDIR/output/greenlight_output_20240613_1200.csv \
  --start_date 1983-01-01 \
  --end_date 1983-01-02 \
  --input_data_file $BASEDIR/models/katzin_2021/input_data/energyPlus_original/JPN_Tokyo.Hyakuri.477150_IWECEPW.csv \
  --mods $BASEDIR/models/katzin_2021/definition/lamp_hps_katzin_2021.json
echo "Example script executed. You can now start developing with Greenlight."