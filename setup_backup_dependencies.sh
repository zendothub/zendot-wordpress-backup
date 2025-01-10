#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt update -y

# Install required packages
echo "Installing zip..."
sudo apt install zip -y

echo "Installing MySQL Client..."
sudo apt install mysql-client -y

# Verify installations
echo "Verifying installed packages..."
zip --version
mysqldump --version
date --version

echo "Setup complete. All required dependencies have been installed."
