#!/bin/bash

font_array=("otf-font-awesome" "ttf-jetbrains-mono-nerd" "ttf-jetbrains-mono" "otf-font-awesome-4" "ttf-droid" "ttf-fantasque-sans-mono" "adobe-source-code-pro-fonts" "noto-fonts-emoji")
base_pkgs=("base-devel" "wget" "sudo" "git" "zip" "unzip")
baseApps_pkgs=("hyprland" "kitty" "jq" "mako" "waybar-hyprland" "swww" "swaylock-effects" "wofi" "thunar" "pavucontrol" "brightnessctl" "sddm-git" "sddm-sugar-candy-git")
software_pkgs=("nodejs" "npm" "audacious" "btop" "neofetch" "firefox" "tor" "jetbrains-toolbox" "nvim" "code" "thunderbird" "gimp" "libreoffice-fresh" "geogebra" "kcalc" "flatpak" "gparted" "xreader" "firewalld" "keepassxc" "vlc" "obsidian" "onedrive" "discord" "steam")

# $EUID is the variable that hold the "effective user ID."
# The EUID for root is 0
# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] This script should not be executed as root! Exiting......."
    exit 1
fi

# "tput setaf x" sets color to x
# "tput sgr0" reset color to standard
# Basic output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"

# Redirects all output to the log files
LOG_FILE="install.log"
exec > >(tee -i "$LOG_FILE") 2>&1

# Exit on any error
set -e

install_package() {
    if yay -Q "$1" &>> /dev/null; then
        echo -e "${OK} $1 is already installed. Skipping..."
    else
        echo -e "${NOTE} Installing $1 ..."
        yay -S --noconfirm "$1" 2>&1
        # making sure package installed
        if yay -Q "$1" &>> /dev/null; then
            echo -e "${OK} $1 was installed."
        else
            # something is missing, exiting to review log
            echo -e "${ERROR} $1 failed to install :( , please check the install.log. You may need to install manually! Sorry, I have tried :("
            exit 1
        fi
    fi
}

perform_system_update() {
    printf "\n%s - Performing a full system update to avoid issues.... \n" "${NOTE}"
    yay
}

cd ~/
clear

# Check for AUR helper and install yay if not found
ISAUR=$(command -v yay)
if [ -n "$ISAUR" ]; then
    printf "\n%s - AUR helper was located, moving on.\n" "${OK}"
else 
    printf "\n%s - AUR helper was NOT located\n" "$WARN"
    printf "\n%s - Installing yay from AUR\n" "${NOTE}"
    git clone https://aur.archlinux.org/yay-bin.git || { printf "%s - Failed to clone yay from AUR\n" "${ERROR}"; exit 1; }
    cd yay-bin || { printf "%s - Failed to enter yay-bin directory\n" "${ERROR}"; exit 1; }
    makepkg -si --noconfirm 2>&1 || { printf "%s - Failed to install yay from AUR\n" "${ERROR}"; exit 1; }
    cd ..
fi

perform_system_update

# INSTALL PACKAGES

for pkgs in "${base_pkgs[@]}"; do
    install_package "$pkgs"
done

for pkgs in "${baseApps_pkgs[@]}"; do
    install_package "$pkgs"
done

for pkgs in "${software_pkgs[@]}"; do
    install_package "$pkgs"
done

for font in "${font_array[@]}"; do
    install_package "$font"
done