#!/bin/bash
# Arch Linux Setup Script
# Created with assistance from ChatGPT (OpenAI)
# Adapted by: pedropb69
# Usage: bash arch-setup.sh
# Run on a fresh Arch Linux installation

set -e

# --- Temporary sudo without password ---
TMP_SUDOERS=$(mktemp)
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/yay" > "$TMP_SUDOERS"
sudo chmod 440 "$TMP_SUDOERS"
sudo cp "$TMP_SUDOERS" /etc/sudoers.d/99_tmp_nopasswd

# --- Installation functions ---
install_pacman_pkg() {
    for pkg in "$@"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo "✅ $pkg already installed (pacman)"
        else
            echo "📦 Installing $pkg..."
            sudo pacman -S --noconfirm "$pkg"
        fi
    done
}

install_yay_pkg() {
    for pkg in "$@"; do
        if yay -Qi "$pkg" &>/dev/null; then
            echo "✅ $pkg already installed (yay/AUR)"
        else
            echo "📦 Installing $pkg (yay/AUR)..."
            yay -S --noconfirm "$pkg"
        fi
    done
}

install_flatpak_pkg() {
    for pkg in "$@"; do
        if flatpak list | grep -q "$pkg"; then
            echo "✅ $pkg already installed (flatpak)"
        else
            echo "📦 Installing $pkg (flatpak)..."
            flatpak install -y flathub "$pkg"
        fi
    done
}

# --- Keep sudo session alive ---
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Check internet connection ---
if ! ping -c 1 archlinux.org &>/dev/null; then
    echo "❌ No internet connection. Please check and try again."
    sudo rm -f /etc/sudoers.d/99_tmp_nopasswd
    rm -f "$TMP_SUDOERS"
    exit 1
fi

echo "[1/10] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/10] Installing basic utilities..."
install_pacman_pkg wget curl unzip p7zip unrar htop man-db nano rsync

echo "[3/10] Installing and configuring UFW + GUFW..."
install_pacman_pkg ufw gufw
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "[4/10] Installing yay..."
if ! command -v yay &>/dev/null; then
    install_pacman_pkg base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "✅ yay already installed"
fi

echo "[5/10] Installing packages via yay..."
install_yay_pkg librewolf-bin qimgv-git

echo "[6/10] Installing Flatpak and ProtonPlus..."
install_pacman_pkg flatpak
install_flatpak_pkg com.vysp3r.ProtonPlus

echo "[7/10] Enabling multilib repository..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    sudo pacman -Syu --noconfirm
    echo "✅ multilib enabled"
else
    echo "✅ multilib already enabled"
fi

echo "[8/10] Installing additional programs..."
install_pacman_pkg steam vlc flameshot geany kitty fish libreoffice-fresh okular fastfetch btop

echo "[9/10] Installing multimedia codecs..."
install_pacman_pkg gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg

echo "[10/10] Setting Fish as default shell..."
if [ "$SHELL" != "/usr/bin/fish" ]; then
    chsh -s /usr/bin/fish
    echo "✅ Fish set as default shell"
else
    echo "✅ Fish is already the default shell"
fi

echo "[Extra] Fixing Apple keyboard FN keys..."
echo "options hid_apple fnmode=0" | sudo tee /etc/modprobe.d/hid_apple.conf
sudo mkinitcpio -P

echo "[Extra] Cleaning orphan packages and cache..."
orphans=$(pacman -Qdtq)
if [ -n "$orphans" ]; then
    sudo pacman -Rns $orphans --noconfirm
fi
yay -Sc --noconfirm

# --- Remove temporary sudo ---
sudo rm -f /etc/sudoers.d/99_tmp_nopasswd
rm -f "$TMP_SUDOERS"

echo "✅ Installation completed!"
echo "💡 It's recommended to reboot the system now to apply all changes."
