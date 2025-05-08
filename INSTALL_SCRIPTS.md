# NatDots Installation Scripts

This directory contains two scripts to automate the installation process of the NatDots system:

1. `install.sh` - Initial installation script to run after setting up the network
2. `post-install.sh` - Post-installation script to run after the first reboot

## Prerequisites

Before running these scripts, make sure you have:

1. Installed NixOS using the [official guide](https://nixos.org/download.html)
2. Set up network connectivity

### Setting up network connectivity

If you haven't set up your network yet, you can use one of the following methods:

#### Method 1: Using wpa_passphrase

```bash
wpa_passphrase your-ESSID your-passphrase | sudo tee /etc/wpa_supplicant.conf 
sudo systemctl restart wpa_supplicant
```

#### Method 2: Using wpa_cli

```bash
sudo systemctl start wpa_supplicant
wpa_cli

add_network 0
set_network 0 ssid "your SSID"
set_network 0 psk "your password"
enable network 0
exit
```

Verify connectivity with `ping 1.1.1.1`

## Installation Process

### Step 1: Initial Installation

1. Download the `install.sh` script:

```bash
curl -L https://github.com/Nat2-Dev/dots/raw/main/install.sh -o install.sh
chmod +x install.sh
```

2. Run the script:

```bash
./install.sh
```

This script will:
- Check network connectivity
- Enable git
- Download and run disk configuration
- Clone the repository
- Prompt for SSH key setup
- Install the flake
- Reboot the system

### Step 2: First Login

After the reboot, log in with:
- Username: `nat`
- Password: `lolzthisaintsecure!`

### Step 3: Post-Installation Setup

1. Download the `post-install.sh` script:

```bash
curl -L https://github.com/Nat2-Dev/dots/raw/main/post-install.sh -o post-install.sh
chmod +x post-install.sh
```

2. Run the script:

```bash
./post-install.sh
```

This script will guide you through:
- Changing the default password
- Setting up configuration files
- Fingerprint reader setup (optional)
- Atuin shell history sync setup (optional)
- System rebuild

## Manual Installation Steps

If you prefer to run the commands manually, or if the scripts fail for any reason, you can follow the steps in the main [README.md](./README.md) file.

## Troubleshooting

If you encounter any issues during the installation process, check the following:

1. **Network Connectivity**: Ensure you have a working internet connection before running the scripts.
2. **Disk Space**: Make sure you have enough disk space for the installation.
3. **Hardware Compatibility**: Some hardware components might require additional configuration.

For more help, please open an issue on the GitHub repository.