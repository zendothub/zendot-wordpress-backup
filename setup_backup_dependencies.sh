#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt update -y

# Install required packages
echo "Installing zip..."
sudo apt install zip -y


sudo apt install mariadb-client


# Verify installations
echo "Verifying installed packages..."
zip --version
mysqldump --version
date --version

echo "Setup complete. All required dependencies have been installed."
