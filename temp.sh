#!/bin/bash

# Enable RPM Fusion repositories
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Download the Sunshine RPM package
wget https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-fedora-40-$(uname -m).rpm

# Install the Sunshine package
sudo dnf install -y ./sunshine-fedora-40-$(uname -m).rpm

# Start and enable the Sunshine service
sudo systemctl start sunshine
sudo systemctl enable sunshine

echo "Sunshine installation and setup complete!"
