#!/usr/bin/env bash

# NatDots Installation Script
# This script automates the post-network setup installation process

set -e # Exit on any error

echo "==== NatDots Installation Automation ===="
echo "This script will automate the installation process after network setup."
echo "Make sure you have already set up network connectivity before running this script."

# Verify network connectivity
echo -n "Checking network connectivity... "
if ping -c 1 1.1.1.1 &> /dev/null; then
    echo "Success!"
else
    echo "Failed!"
    echo "Error: No internet connection detected. Please set up your network first."
    echo "You can use the following commands to connect to WiFi:"
    echo "  sudo systemctl start wpa_supplicant"
    echo "  wpa_cli"
    echo "  > add_network 0"
    echo "  > set_network 0 ssid \"your SSID\""
    echo "  > set_network 0 psk \"your password\""
    echo "  > enable network 0"
    echo "  > exit"
    exit 1
fi

# Get sudo privileges and maintain them
echo "Acquiring root permissions..."
sudo -v
# Keep sudo privileges active
while true; do sudo -v; sleep 60; done &
KEEP_SUDO_PID=$!

# Function to clean up the background sudo process on exit
cleanup() {
    kill $KEEP_SUDO_PID 2>/dev/null
}
trap cleanup EXIT

# Enable git in the configuration
echo "Enabling git..."
sudo sed -i 's/^{$/{\n  programs.git.enable = true;/' /etc/nixos/configuration.nix
sudo nixos-rebuild switch

# Download and run the disk configuration
echo "Downloading and running disk configuration..."
curl -L https://github.com/Nat2-Dev/dots/raw/main/zoomies/disk-config.nix -o /tmp/disk-config.nix
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount /tmp/disk-config.nix

# Generate NixOS configuration
echo "Generating NixOS configuration..."
sudo nixos-generate-config --root /mnt
cd /mnt/etc/nixos

# Clone the repository to the NixOS configuration directory
echo "Cloning nat-dots repository..."
sudo rm -f *
sudo git clone https://github.com/Nat2-Dev/dots.git .

# Prompt user for SSH key setup
echo ""
echo "SSH Key Setup"
read -p "Do you want to add an SSH private key? (y/n): " add_ssh_key
if [[ "$add_ssh_key" =~ ^[Yy]$ ]]; then
    echo "Please enter the path to your SSH private key:"
    read ssh_key_path
    
    if [ -f "$ssh_key_path" ]; then
        sudo mkdir -p /mnt/etc/ssh/
        sudo cp "$ssh_key_path" /mnt/etc/ssh/id_rsa
        sudo chmod 600 /mnt/etc/ssh/id_rsa
        echo "SSH key added!"
    else
        echo "Warning: SSH key file not found. Proceeding without SSH key."
    fi
else
    echo "Proceeding without SSH key."
fi

# Install the flake
echo "Installing the flake..."
sudo nixos-install --flake .#zoomies --no-root-passwd

echo "Installation complete! The system will now reboot."
echo "After reboot, log in with:"
echo "  Username: nat"
echo "  Password: lolzthisaintsecure!"
echo "Remember to change this password immediately after login by running 'passwd nat'"
echo ""
echo "Post-installation tasks:"
echo "1. Change your password: passwd nat"
echo "2. Move config to local directory: mkdir ~/etc; sudo mv /etc/nixos ~/etc"
echo "3. Link to /etc/nixos: sudo ln -s ~/etc/nixos /etc"
echo "4. Change permissions: sudo chown -R \$(id -un):users ~/etc/nixos"
echo "5. Setup fingerprint reader (optional): sudo fprintd-enroll -f right-index-finger nat"
echo "6. Setup atuin for shell history: atuin login; atuin sync"

read -p "Press Enter to unmount and reboot..."
sudo umount -R /mnt
sudo reboot