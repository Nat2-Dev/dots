#!/usr/bin/env bash

# NatDots Post-Installation Script
# This script automates the post-installation tasks after the first reboot

set -e # Exit on any error

echo "==== NatDots Post-Installation Setup ===="
echo "This script will automate the post-installation tasks."

# Function to print current step
print_step() {
    echo -e "\n\033[1;34m==== $1 ====\033[0m"
}

# Change password
print_step "Changing default password"
echo "For security reasons, you should change your default password."
read -p "Do you want to change your password now? (y/n): " change_password
if [[ "$change_password" =~ ^[Yy]$ ]]; then
    passwd
    echo "Password changed successfully!"
else
    echo "Skipping password change. Remember to change it later for security!"
fi

# Move config to local directory and fix permissions
print_step "Setting up configuration files"
if [ -L "/etc/nixos" ]; then
    echo "Configuration is already properly set up."
else
    echo "Moving configuration to home directory..."
    mkdir -p ~/etc
    sudo mv /etc/nixos ~/etc/
    sudo ln -s ~/etc/nixos /etc/
    sudo chown -R $(id -un):users ~/etc/nixos
    sudo chown nat -R ~/etc/nixos
    sudo chown nat -R ~/etc/nixos/.*
    echo "Configuration files moved and linked successfully!"
fi

# Setup fingerprint reader (optional)
print_step "Fingerprint Reader Setup"
read -p "Do you want to set up the fingerprint reader? (y/n): " setup_fingerprint
if [[ "$setup_fingerprint" =~ ^[Yy]$ ]]; then
    echo "Setting up fingerprint reader..."
    echo "You may need to swipe your finger across the fingerprint sensor instead of simply laying it there."
    sudo fprintd-enroll -f right-index-finger nat
    echo "Verifying fingerprint..."
    sudo fprintd-verify nat
else
    echo "Skipping fingerprint reader setup."
fi

# Setup Atuin for shell history
print_step "Setting up Atuin shell history sync"
read -p "Do you want to set up Atuin for shell history sync? (y/n): " setup_atuin
if [[ "$setup_atuin" =~ ^[Yy]$ ]]; then
    echo "Setting up Atuin..."
    atuin login
    atuin sync
    echo "Atuin setup complete!"
else
    echo "Skipping Atuin setup."
fi

print_step "Rebuilding system"
read -p "Do you want to rebuild the system to apply all changes? (y/n): " rebuild_system
if [[ "$rebuild_system" =~ ^[Yy]$ ]]; then
    echo "Rebuilding system..."
    cd ~/etc/nixos
    sudo nixos-rebuild switch --flake .#
    echo "System rebuilt successfully!"
else
    echo "Skipping system rebuild."
fi

print_step "Post-installation complete!"
echo "Your NatDots setup is now complete! You may need to restart some applications or services for all changes to take effect."
echo "To rebuild your system in the future, run: cd ~/etc/nixos && sudo nixos-rebuild switch --flake .#"
echo "Enjoy your new NixOS installation!"