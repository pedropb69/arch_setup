# Arch Linux Setup Script

This script automates the setup of a fresh Arch Linux installation.  
It installs basic utilities, yay (AUR helper), Flatpak, multimedia codecs, Steam, and other programs, and configures UFW firewall and Fish shell.  

## Features

- Updates the system
- Installs basic utilities (wget, curl, htop, nano, etc.)
- Installs and configures UFW + GUFW firewall
- Installs yay (AUR helper) and selected AUR packages
- Installs Flatpak and ProtonPlus
- Enables multilib repository
- Installs Steam, VLC, Flameshot, Geany, Kitty, LibreOffice, Okular, Fastfetch, btop
- Installs multimedia codecs
- Sets Fish as the default shell
- Fixes Apple keyboard FN keys
- Cleans orphan packages and caches

## Usage

Run the script directly from GitHub with:

```bash
bash <(curl -s https://raw.githubusercontent.com/pedropb69/arch_setup/main/arch-setup.sh)

> Make sure you have an internet connection. The script temporarily disables sudo password prompts for pacman and yay during execution.



Notes

Tested on fresh Arch Linux installations.

Recommended to reboot after the script finishes to apply all changes.

## Credits

This script was originally created with the help of ChatGPT (OpenAI) and adapted by the repository owner.
