# Arch Linux Setup Script

This repository contains a Bash script to automatically set up a fresh Arch Linux installation with common utilities, AUR packages, Flatpak apps, multimedia codecs, and more.  

⚠️ **Note:** This script was created with my personal workflow and favorite packages in mind, but anyone is welcome to use it.

## Features

- Updates the system
- Installs basic utilities (wget, curl, htop, nano, etc.)
- Installs and configures UFW + GUFW firewall
- Installs yay (AUR helper) and selected AUR packages
- Installs Flatpak and selected Flatpak apps
- Enables multilib repository
- Installs additional programs (Steam, VLC, Fish, LibreOffice, etc.)
- Installs multimedia codecs
- Sets Fish as the default shell and disables the welcome message
- Fixes Apple keyboard FN keys
- Cleans orphan packages and cache

## Usage

Run the script directly from GitHub:

```bash
bash <(curl -s https://raw.githubusercontent.com/pedropb69/arch_setup/main/arch-setup.sh)
