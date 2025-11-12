"""
Unit tests for the GreenLight utils module.
"""

import unittest
import os
import tempfile

import greenlight
import greenlight.utils


class TestGreenLightUtils(unittest.TestCase):
    """Test cases for the GreenLight utilities."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()

    def tearDown(self):
        """Clean up test fixtures."""
        # Clean up temp directory if it exists
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_utils_module_exists(self):
        """Test that utils module exists and has expected functions."""
        self.assertTrue(hasattr(greenlight, 'utils'))
        self.assertTrue(hasattr(greenlight.utils, 'copy_builtin_models'))

    def test_copy_builtin_models_creates_directory(self):
        """Test that copy_builtin_models creates the target directory."""
        target_dir = os.path.join(self.temp_dir, "test_models")
        self.assertFalse(os.path.exists(target_dir))

        greenlight.utils.copy_builtin_models(target_dir)

        self.assertTrue(os.path.exists(target_dir))

    def test_copy_builtin_models_copies_files(self):
        """Test that copy_builtin_models actually copies model files."""
        target_dir = os.path.join(self.temp_dir, "test_models")

        greenlight.utils.copy_builtin_models(target_dir)

        # Check that some expected files exist (copy_builtin_models creates a "models" subdir)
        models_dir = os.path.join(target_dir, "models")
        katzin_readme = os.path.join(models_dir, "katzin_2021", "readme.txt")
        self.assertTrue(os.path.exists(katzin_readme), f"Expected file not found: {katzin_readme}")

        main_model = os.path.join(models_dir, "katzin_2021", "definition", "main_katzin_2021.json")
        self.assertTrue(os.path.exists(main_model), f"Expected file not found: {main_model}")

    def test_copy_builtin_models_with_default_path(self):
        """Test copy_builtin_models with default (empty) target path."""
        # Change to temp directory to avoid cluttering current directory
        original_cwd = os.getcwd()
        try:
            os.chdir(self.temp_dir)
            greenlight.utils.copy_builtin_models()

            # Should create models in current directory
            models_dir = os.path.join(self.temp_dir, "models")
            self.assertTrue(os.path.exists(models_dir))

        finally:
            os.chdir(original_cwd)


if __name__ == '__main__':
    unittest.main()
