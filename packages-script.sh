software_array=(
"audacious"
"firefox"
"tor"
"intellij toolbox"
"nvim"
"code (VsCode)"
"thunderbird"
"gimp"
"libreoffice-fresh"
"geogebra"
"kcalc"
"flatpak"
"gparted"
"xreader"
"firewalld"
"keepassxc"
"vlc"
"obsidian"
"onedrive"
"discord"
"steam"
)

for element in "${software_array[@]}"; do
    if ! yay -Qs "^$element\$" &>/dev/null; then
        echo "Installing $element..."
        yay -S "$element"
    else
        echo "$element is already installed."
    fi
done
