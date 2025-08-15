#!/bin/bash
set -e

# --- Funções de instalação ---
install_pacman_pkg() {
    for pkg in "$@"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo "✅ $pkg já instalado (pacman)"
        else
            echo "📦 Instalando $pkg..."
            sudo pacman -S --noconfirm "$pkg"
        fi
    done
}

install_yay_pkg() {
    for pkg in "$@"; do
        if yay -Qi "$pkg" &>/dev/null; then
            echo "✅ $pkg já instalado (yay/AUR)"
        else
            echo "📦 Instalando $pkg (yay/AUR)..."
            yay -S --noconfirm "$pkg"
        fi
    done
}

install_flatpak_pkg() {
    for pkg in "$@"; do
        if flatpak list | grep -q "$pkg"; then
            echo "✅ $pkg já instalado (flatpak)"
        else
            echo "📦 Instalando $pkg (flatpak)..."
            flatpak install -y flathub "$pkg"
        fi
    done
}

# --- Manter sessão sudo ativa ---
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Checar conexão ---
if ! ping -c 1 archlinux.org &>/dev/null; then
    echo "❌ Sem conexão com a internet. Verifique e tente novamente."
    exit 1
fi

echo "[1/10] Atualizando sistema..."
sudo pacman -Syu --noconfirm

echo "[2/10] Instalando utilitários básicos..."
install_pacman_pkg wget curl unzip p7zip unrar htop man-db nano rsync

echo "[3/10] Instalando e configurando UFW + GUFW..."
install_pacman_pkg ufw gufw
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "[4/10] Instalando yay..."
if ! command -v yay &>/dev/null; then
    install_pacman_pkg base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "✅ yay já instalado"
fi

echo "[5/10] Instalando pacotes via yay..."
install_yay_pkg librewolf-bin qimgv-git

echo "[6/10] Instalando Flatpak e ProtonPlus..."
install_pacman_pkg flatpak
install_flatpak_pkg com.vysp3r.ProtonPlus

echo "[7/10] Ativando repositório multilib..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    sudo pacman -Syu --noconfirm
    echo "✅ multilib ativado"
else
    echo "✅ multilib já está ativo"
fi

echo "[8/10] Instalando programas adicionais..."
install_pacman_pkg steam vlc flameshot geany kitty fish libreoffice-fresh okular fastfetch btop

echo "[9/10] Instalando codecs multimídia..."
install_pacman_pkg gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg

echo "[10/10] Definindo Fish como shell padrão..."
if [ "$SHELL" != "/usr/bin/fish" ]; then
    chsh -s /usr/bin/fish
    echo "✅ Fish definido como shell padrão"
else
    echo "✅ Fish já é o shell padrão"
fi

echo "[Extra] Corrigindo teclas FN no teclado Apple..."
echo "options hid_apple fnmode=0" | sudo tee /etc/modprobe.d/hid_apple.conf
sudo mkinitcpio -P

echo "[Extra] Limpando pacotes órfãos e cache..."
sudo pacman -Rns $(pacman -Qdtq) --noconfirm || true
yay -Sc --noconfirm

echo "✅ Instalação concluída!"
echo "💡 Recomendo reiniciar o sistema agora para aplicar todas as alterações."
