#!/bin/bash
 
# Update package list and install python3-venv if not installed

echo "Updating system and installing python3-venv..."

sudo apt update && sudo apt install -y python3-venv python3-pip
 
# Create virtual environment

echo "Creating virtual environment..."

python3 -m venv myenv
 
# Activate virtual environment

echo "Activating virtual environment..."

source myenv/bin/activate
 
# Install AWS CLI inside the virtual environment

echo "Installing AWS CLI inside the virtual environment..."

pip install awscli --upgrade
 
# Start the Python application

echo "Starting app.py..."

python3 app.py   # Run in the background
 
# Wait for app.py to run for 5 minutes and then create a backup

./backup.sh

 