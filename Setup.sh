#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo"
  exit
fi

# Function to update system packages
update_packages() {
  echo "Updating system packages..."
  dnf update -y
}

# Function to install packages
install_packages() {
  # Read list of packages from file
  packages=()
  while IFS= read -r line; do
    packages+=("$line")
  done < files/packages.txt

  # Install packages
  for package in "${packages[@]}"; do
    dnf install -y "$package"
  done
}

# Function to create .config directory in all users' home directories
create_config_directories() {
  echo "Creating .config directory in all users' home directories..."
  for dir in /home/*; do
    if [ -d "$dir" ]; then
      mkdir -p "$dir/.config"
      chown $(basename "$dir"):$(basename "$dir") "$dir/.config"
      echo ".config directory created for user $(basename "$dir")"
    fi
  done
}

# Menu to select which parts of the script to run
while true; do
  echo "Which parts of the script would you like to run?"
  echo "1. Update and install packages"
  echo "2. Create .config directories"
  echo "Enter 'all' to run all tasks"
  echo "Enter 'q' to quit"
  read -p "Enter your choice (number, 'all', or 'q'): " choice

  case "$choice" in
    "1")
      update_packages
      install_packages
      ;;
    "2")
      create_config_directories
      ;;
    "all")
      update_packages
      install_packages
      create_config_directories
      ;;
    "q")
      break
      ;;
    *)
      echo "Invalid choice. Please enter a valid option."
      ;;
  esac
done

echo "The install for the selected options was completed!"
