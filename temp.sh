#!/bin/bash

# Install the Sunshine package
sudo dnf install -y ./sunshine-fedora-40-amd64.rpm

# Start and enable the Sunshine service
sudo systemctl start sunshine
sudo systemctl enable sunshine

echo "Sunshine installation and setup complete!"
