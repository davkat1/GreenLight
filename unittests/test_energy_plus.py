"""
Unit tests for the GreenLight EnergyPlus functionality.
"""

import unittest
import os
import tempfile

import greenlight


class TestEnergyPlusConversion(unittest.TestCase):
    """Test cases for EnergyPlus weather data conversion."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()

    def tearDown(self):
        """Clean up test fixtures."""
        # Clean up temp directory if it exists
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_convert_energy_plus_function_exists(self):
        """Test that the convert_energy_plus function exists and is callable."""
        self.assertTrue(hasattr(greenlight, 'convert_energy_plus'))
        self.assertTrue(callable(greenlight.convert_energy_plus))

    def test_convert_energy_plus_with_nonexistent_file(self):
        """Test convert_energy_plus behavior with nonexistent input file."""
        nonexistent_file = os.path.join(self.temp_dir, "nonexistent.csv")
        output_file = os.path.join(self.temp_dir, "output.csv")

        # Should raise FileNotFoundError for nonexistent file
        with self.assertRaises(FileNotFoundError):
            greenlight.convert_energy_plus(
                energy_plus_csv_path=nonexistent_file,
                output_file_path=output_file
            )

    def test_convert_energy_plus_parameters(self):
        """Test that convert_energy_plus accepts expected parameters."""
        # This test just checks that the function signature accepts expected parameters
        # without actually running it with valid data
        try:
            # Should not raise TypeError for missing required parameters
            greenlight.convert_energy_plus(
                energy_plus_csv_path="dummy.csv",
                output_file_path="dummy_out.csv"
            )
        except (FileNotFoundError, ValueError, IOError):
            # These exceptions are expected for dummy files
            pass
        except TypeError as e:
            # This would indicate a problem with the function signature
            self.fail(f"Function signature issue: {e}")


if __name__ == '__main__':
    unittest.main()
