"""
Unit tests for the GreenLight core module.
"""

import unittest
import os
import tempfile

import greenlight


class TestGreenLightCore(unittest.TestCase):
    """Test cases for the GreenLight core functionality."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()

    def tearDown(self):
        """Clean up test fixtures."""
        # Clean up temp directory if it exists
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_greenlight_import(self):
        """Test that greenlight can be imported successfully."""
        self.assertTrue(hasattr(greenlight, 'GreenLight'))
        self.assertTrue(hasattr(greenlight, 'convert_energy_plus'))
        self.assertTrue(hasattr(greenlight, 'copy_builtin_models'))

    def test_greenlight_instance_creation(self):
        """Test that a GreenLight instance can be created with default parameters."""
        gl = greenlight.GreenLight()
        self.assertIsNotNone(gl)
        self.assertIsNotNone(gl.input_prompt)

    def test_greenlight_instance_with_base_path(self):
        """Test that a GreenLight instance can be created with custom base_path."""
        gl = greenlight.GreenLight(base_path=self.temp_dir)
        self.assertIsNotNone(gl)
        self.assertEqual(gl.base_path, self.temp_dir)

    def test_copy_builtin_models(self):
        """Test that builtin models can be copied to a directory."""
        target_dir = os.path.join(self.temp_dir, "models")
        greenlight.copy_builtin_models(target_dir)

        # Check that models directory was created (copy_builtin_models creates a "models" subdir)
        models_dir = os.path.join(target_dir, "models")
        self.assertTrue(os.path.exists(models_dir))

        # Check that some expected model files exist
        katzin_model = os.path.join(models_dir, "katzin_2021", "definition", "main_katzin_2021.json")
        self.assertTrue(os.path.exists(katzin_model))

    def test_package_version(self):
        """Test that the package has a version."""
        # The package should have some way to identify its version
        has_version = (hasattr(greenlight, 'version') or
                       hasattr(greenlight, '__version__') or
                       greenlight.version)
        self.assertTrue(has_version)


if __name__ == '__main__':
    unittest.main()
