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

  # Install packages and log missing ones
  echo "Installing packages..."
  missing_packages=()
  for package in "${packages[@]}"; do
    if ! dnf install -y "$package"; then
      missing_packages+=("$package")
    fi
  done

  # Log missing packages
  if [ ${#missing_packages[@]} -ne 0 ]; then
    echo "The following packages were not found in the dnf repository:" > missing_packages.log
    for package in "${missing_packages[@]}"; do
      echo "$package" >> missing_packages.log
    done
    echo "Missing packages have been logged to missing_packages.log"
  fi

  # Download and install JetBrainsMono font
  echo "Installing JetBrainsMono font..."
  wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
  && cd ~/.local/share/fonts \
  && unzip JetBrainsMono.zip \
  && rm JetBrainsMono.zip \
  && fc-cache -fv
}

# Function to create .config directory and copy files
setup_user_configs() {
  echo "Setting up user .configs..."
  for dir in /home/*; do
    if [ -d "$dir" ]; then
      mkdir -p "$dir/.config"
      chown $(basename "$dir"):$(basename "$dir") "$dir/.config"
      cp files/Wallpaper.jpg "$dir/.config/"
      cp -r files/dotconfigs/* "$dir/.config/"
      chown -R $(basename "$dir"):$(basename "$dir") "$dir/.config/"
      echo ".config directory and files set up for user $(basename "$dir")"
    fi
  done
}

# Menu to select which parts of the script to run
while true; do
  echo "Which parts of the script would you like to run?"
  echo "1. Update and install packages"
  echo "2. Set up user .configs"
  echo "Enter 'all' to run all tasks"
  echo "Enter 'q' to quit"
  read -p "Enter your choice (number, 'all', or 'q'): " choice

  case "$choice" in
    "1")
      update_packages
      install_packages
      ;;
    "2")
      setup_user_configs
      ;;
    "all")
      update_packages
      install_packages
      setup_user_configs
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
