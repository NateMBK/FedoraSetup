#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo"
  exit
fi

# Define log file
LOGFILE="$(dirname "$0")/install_log.txt"

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

# Function to configure PCI passthrough
configure_pci_passthrough() {
  # Detect Nvidia GPU
  echo "Detecting Nvidia GPU..."
  GPU_ID=$(lspci | grep -i nvidia | cut -d ' ' -f 1 | sed 's/\./:/')
  AUDIO_ID=$(lspci | grep -i nvidia | grep -i audio | cut -d ' ' -f 1 | sed 's/\./:/')
  GPU_IDS="$GPU_ID $AUDIO_ID"

  # Disable nouveau driver
  echo "Disabling nouveau driver..."
  echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
  mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
  dracut /boot/initramfs-$(uname -r).img $(uname -r)

  # Enable IOMMU and VFIO for AMD
  echo "Enabling IOMMU and VFIO for AMD..."
  GRUB_CMDLINE_LINUX_DEFAULT="quiet splash iommu=pt amd_iommu=on vfio_iommu_type1.allow_unsafe_interrupts=1"
  echo "GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE_LINUX_DEFAULT\"" >> /etc/default/grub
  grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  echo "options vfio-pci ids=$GPU_IDS" >> /etc/modprobe.d/vfio.conf
  echo "vfio-pci" >> /etc/modules-load.d/vfio-pci.conf
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
echo "Which parts of the script would you like to run?"
echo "1. Update and install packages"
echo "2. Configure PCI passthrough"
echo "3. Create .config directories"
echo "Enter 'debug' for debug mode"
echo "Enter 'all' to run all tasks"
read -p "Enter your choice (number, 'debug', or 'all'): " choice

case "$choice" in
  "1")
    update_packages
    install_packages
    ;;
  "2")
    configure_pci_passthrough
    ;;
  "3")
    create_config_directories
    ;;
  "debug")
    # Redirect all output to log file
    exec > >(tee -a "$LOGFILE") 2>&1
    ;;
  "all")
    update_packages
    install_packages
    configure_pci_passthrough
    create_config_directories
    ;;
  *)
    echo "Invalid choice. Please run the script again."
    exit
    ;;
esac

echo "The install for the selected options was completed!"
