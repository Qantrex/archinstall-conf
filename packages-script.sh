#!/bin/bash

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] This script should not be executed as root! Exiting......."
    exit 1
fi

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"

LOG_FILE="install.log"

# Redirect all output and errors to the log file
exec > >(tee -i "$LOG_FILE") 2>&1

# Exit on any error
set -e

software_array=("audacious" "firefox" "tor" "jetbrains-toolbox" "nvim" "code" "thunderbird" "gimp" "libreoffice-fresh" "geogebra" "kcalc" "flatpak" "gparted" "xreader" "firewalld" "keepassxc" "vlc" "obsidian" "onedrive" "discord" "steam")

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

cd ~/
clear

# Check for AUR helper and install yay if not found
ISAUR=$(command -v yay || command -v paru)
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

printf "\n%s - Performing a full system update to avoid issues.... \n" "${NOTE}"
yay

for element in "${software_array[@]}"; do
    install_package "$element"
done

font_array=("otf-font-awesome" "ttf-jetbrains-mono-nerd" "ttf-jetbrains-mono" "otf-font-awesome-4" "ttf-droid" "ttf-fantasque-sans-mono" "adobe-source-code-pro-fonts" "noto-fonts-emoji")

for font in "${font_array[@]}"; do
    install_package "$font"
done
