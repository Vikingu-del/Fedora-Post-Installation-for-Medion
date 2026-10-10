#!/usr/bin/env bash
# Fedora 44 post-install setup script
# Last verified: April 28, 2026
# Usage: bash fedora44-setup.sh
# Edit GPU section below to match your hardware before running.

set -euo pipefail

echo "──────────────────────────────────────────"
echo " Fedora 44 Post-Install Setup"
echo "──────────────────────────────────────────"

## ── DNF5 OPTIMISATION ──────────────────────────────────────────────────────
echo "[1/10] Configuring DNF5..."
grep -q 'max_parallel_downloads' /etc/dnf/dnf.conf || {
  echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
  echo 'fastestmirror=True'        | sudo tee -a /etc/dnf/dnf.conf
  echo 'defaultyes=True'           | sudo tee -a /etc/dnf/dnf.conf
  echo 'keepcache=True'            | sudo tee -a /etc/dnf/dnf.conf
}

## ── SYSTEM UPDATE ──────────────────────────────────────────────────────────
echo "[2/10] Updating system..."
sudo dnf upgrade --refresh -y

## ── RPM FUSION ─────────────────────────────────────────────────────────────
echo "[3/10] Enabling RPM Fusion..."
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

## ── MULTIMEDIA CODECS ──────────────────────────────────────────────────────
echo "[4/10] Installing multimedia codecs..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

sudo dnf install -y --setopt="install_weak_deps=False" \
  gstreamer1-plugins-good \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugins-ugly \
  gstreamer1-plugins-ugly-free \
  gstreamer1-plugin-openh264 \
  gstreamer1-plugin-libav \
  ffmpeg-libs \
  --exclude=PackageKit-gstreamer-plugin

sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

# DVD playback (remove if not needed)
sudo dnf install -y rpmfusion-free-release-tainted libdvdcss

## ── GPU DRIVERS — UNCOMMENT YOUR GPU TYPE ─────────────────────────────────
echo "[5/10] GPU drivers..."

# ── INTEL ──
# sudo dnf install -y intel-media-driver        # Gen 8 (Coffee Lake) and newer
# sudo dnf install -y libva-intel-driver        # Pre-Gen 8 Intel only

# ── AMD ──
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf install -y vulkan-tools mesa-vulkan-drivers rocm-opencl

# ── NVIDIA ──
# NOTE: Check Secure Boot status first: mokutil --sb-state
# sudo dnf install -y akmod-nvidia
# sudo dnf install -y xorg-x11-drv-nvidia-cuda   # optional: CUDA support
# sudo dnf install -y nvidia-vaapi-driver
# echo "Waiting 5 min for NVIDIA kernel module to build..."
# sleep 300
# sudo akmods --force
# modinfo -F version nvidia && echo "NVIDIA module ready." || echo "WARNING: Module not ready — do not reboot yet."

## ── FLATHUB ────────────────────────────────────────────────────────────────
echo "[6/10] Setting up Flathub..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update -y
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub com.mattjakeman.ExtensionManager

## ── GNOME TWEAKS ───────────────────────────────────────────────────────────
echo "[7/10] Applying GNOME settings..."
sudo dnf install -y gnome-tweaks
gsettings set org.gnome.desktop.interface   show-battery-percentage true
gsettings set org.gnome.desktop.interface   font-hinting            'slight'
gsettings set org.gnome.desktop.interface   font-antialiasing       'rgba'
gsettings set org.gnome.nautilus.preferences always-use-location-entry true
touch ~/Templates/Empty\ Document

## ── FONTS ──────────────────────────────────────────────────────────────────
echo "[8/10] Installing fonts..."
sudo dnf install -y \
  mscore-fonts-all \
  google-noto-fonts \
  google-noto-sans-fonts \
  google-noto-serif-fonts

## ── SYSTEM SERVICES ────────────────────────────────────────────────────────
echo "[9/10] Configuring system services..."
sudo systemctl enable fstrim.timer --now
sudo systemctl enable cups --now

# Bluetooth audio codecs
sudo dnf install -y libfreeaptx libldac fdk-aac

# Printing and scanning
sudo dnf install -y hplip cups system-config-printer sane-airscan simple-scan

## ── DEVELOPER TOOLS ────────────────────────────────────────────────────────
echo "[10/10] Installing developer tools..."
sudo dnf install -y @development-tools
sudo dnf install -y git curl wget unzip p7zip p7zip-plugins htop btop neovim fastfetch

## ── CLEANUP ────────────────────────────────────────────────────────────────
sudo dnf autoremove -y

echo ""
echo "──────────────────────────────────────────"
echo " Setup complete."
echo " If you installed NVIDIA drivers, verify"
echo " the module with: modinfo -F version nvidia"
echo " before rebooting."
echo "──────────────────────────────────────────"
