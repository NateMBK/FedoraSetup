#!/bin/bash

# Define log file
LOGFILE="$(dirname "$0")/install_log.txt"

# Function to log messages
log() {
    echo "$(date): $1" | tee -a $LOGFILE
}

# Update system packages
echo "Updating system packages..."
dnf update -y

# List of packages
packages=(
  ntfs-3g
  waybar
  kitty
  firefox
  rofi-wayland
  dxvk-native
  mangohud
  zoom
  discord
  bottles
  papirus-icon-theme
  polkit-gnome
  swaybg
  htop
  ffmpeg
  viewnior
  pavucontrol
  nautilus
  materia-gtk-theme
  wl-clipboard
  oxygen-icon-theme
  okular
  ark
  partitionmanager
  git
  code
  transmission
  gamemode
  dmidecode
  libreoffice
  vkd3d
  vkd3d-proton
  wine
  celluloid
  xdg-desktop-portal-wlr
  virt-manager
  virt-viewer
  spice-gtk3
  spice-protocol
  virtio-win
  spice-vdagent
  adwaita-icon-theme
  hyprland
  hyprland-devel
)

# Install packages
for package in "${packages[@]}"; do
  log "Installing $package..."
  dnf install -y "$package" | tee -a $LOGFILE
done

# Detect Nvidia GPU
log "Detecting Nvidia GPU..."
GPU_ID=$(lspci | grep -i nvidia | cut -d ' ' -f 1)
AUDIO_ID=$(lspci | grep -i nvidia | grep -i audio | cut -d ' ' -f 1)
GPU_IDS="$GPU_ID $AUDIO_ID"

# Disable nouveau driver
log "Disabling nouveau driver..."
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
dracut /boot/initramfs-$(uname -r).img $(uname -r)

# Enable IOMMU and VFIO for AMD
log "Enabling IOMMU and VFIO for AMD..."
echo "iommu=pt iommu=1 vfio_iommu_type1.allow_unsafe_interrupts=1" >> /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
echo "options vfio-pci ids=$GPU_IDS" >> /etc/modprobe.d/vfio.conf
echo "vfio-pci" >> /etc/modules-load.d/vfio-pci.conf

# Create .config directory in all users' home directories
log "Creating .config directory in all users' home directories..."
for dir in /home/*; do
  if [ -d "$dir" ]; then
    mkdir -p "$dir/.config"
    chown $(basename "$dir"):$(basename "$dir") "$dir/.config"
    log ".config directory created for user $(basename "$dir")"
  fi
done

log "All packages installed successfully!"

