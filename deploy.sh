#!/bin/bash

# Variables
APP_DIR="/home/ubuntu/my-python-app"
REPO_URL="https://github.com/SURAJANKOLA19/Automation-of-Uptime-Kuma-setup-.git"
VENV_DIR="$APP_DIR/venv"

# Update and install dependencies
echo "🔹 Updating packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip git

# Clone the GitHub repository
if [ -d "$APP_DIR" ]; then
    echo "✅ App directory exists. Pulling latest changes..."
    cd $APP_DIR && git pull
else
    echo "🔹 Cloning the repository..."
    git clone $REPO_URL $APP_DIR
fi

# Create a virtual environment
cd $APP_DIR
if [ ! -d "$VENV_DIR" ]; then
    echo "🔹 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment and install dependencies
echo "🔹 Activating virtual environment and installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Run the application
echo "🚀 Starting the application..."
nohup python3 app.py > app.log 2>&1 &

echo "🎉 Deployment completed successfully!"
