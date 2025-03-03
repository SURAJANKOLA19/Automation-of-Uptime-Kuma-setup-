#!/bin/bash

# Update package list and install python3-venv if not installed
echo "Updating system and installing python3-venv..."
sudo apt update && sudo apt install -y python3-venv

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv myenv

# Activate virtual environment
echo "Activating virtual environment..."
source myenv/bin/activate

# Run the Python application
echo "Running app.py..."
python3 app.py