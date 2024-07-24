#!/bin/bash

# Define log file
LOGFILE="$(dirname "$0")/install_log.txt"

# Redirect all output to log file
exec > >(tee -a "$LOGFILE") 2>&1

# Update system packages
echo "Updating system packages..."
dnf update -y

# List of packages
packages=(
  gnome-keyring
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
  dnf install -y "$package"
done

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

# Create .config directory in all users' home directories
echo "Creating .config directory in all users' home directories..."
for dir in /home/*; do
  if [ -d "$dir" ]; then
    mkdir -p "$dir/.config"
    chown $(basename "$dir"):$(basename "$dir") "$dir/.config"
    echo ".config directory created for user $(basename "$dir")"
  fi
done

echo "All packages installed successfully!"
