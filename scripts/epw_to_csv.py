import os
import sys

import pandas as pd


def epw_to_csv(epw_path, csv_path):
    if not os.path.isfile(epw_path):
        print(f"Error: Input file '{epw_path}' does not exist.")
        sys.exit(1)

    with open(epw_path, "r") as epw_file:
        lines = epw_file.readlines()

    # Find the start of the data section (first line where the first field looks like a year or date)
    data_start_index = None
    for i, line in enumerate(lines):
        fields = line.strip().split(",")
        if len(fields) > 1:
            # Try to detect a date or year in the first field
            if (fields[0].isdigit() and len(fields[0]) == 4) or (  # Year as 4 digits
                "/" in fields[0] and fields[0].count("/") == 2  # Date format like 1983/1/1
            ):
                data_start_index = i
                break
    if data_start_index is None:
        print("Error: Could not find start of EPW data section.")
        sys.exit(1)

    # Use the line just before the data as the header
    header_index = data_start_index - 1
    header_line = lines[header_index].strip()
    column_names = [col.strip() for col in header_line.split(",")]

    # Read the data rows
    data = []
    for line in lines[data_start_index:]:
        row = [field.strip() for field in line.strip().split(",")]
        if len(row) == len(column_names):
            data.append(row)
        elif len(row) == 0 or all(not x for x in row):
            continue  # skip empty lines
        else:
            print("Error: Data row does not match header column count.")
            sys.exit(1)

    df = pd.DataFrame(data, columns=column_names)

    out_dir = os.path.dirname(os.path.abspath(csv_path))
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir, exist_ok=True)

    df.to_csv(csv_path, index=False)
    print(f"EPW data saved to {csv_path}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Convert EPW weather file to CSV.")
    parser.add_argument("input", help="Path to input EPW file")
    parser.add_argument("output", help="Path to output CSV file")
    args = parser.parse_args()
    epw_to_csv(args.input, args.output)
