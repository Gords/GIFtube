#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

echo -e "${green}
8''''8 8  8'''' ''8'' 8   8 8''''8   8'''' 
8    ' 8  8       8   8   8 8    8   8     
8e     8e 8eeee   8e  8e  8 8eeee8ee 8eeee 
88  ee 88 88      88  88  8 88     8 88    
88   8 88 88      88  88  8 88     8 88    
88eee8 88 88      88  88ee8 88eeeee8 88eee 
${reset}"

# Define config file path early in the script
config_file="$HOME/.giftube_config"

# Function to print error messages
print_error() {
    echo -e "${red}Error: $1${reset}"
}

# Detect the operating system
os_name=$(uname)

# Add this function after the os_name detection and before the dependency checks
install_dependencies() {
    echo "Installing dependencies..."
    
    if [ "$os_name" == "Linux" ]; then
        if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
            # Debian/Ubuntu
            echo "Detected Debian/Ubuntu system"
            sudo apt-get update
            sudo apt-get install -y ffmpeg
            # Install yt-dlp directly
            sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
            sudo chmod a+rx /usr/local/bin/yt-dlp
        elif [ -f /etc/redhat-release ]; then
            # RHEL/CentOS/Fedora
            echo "Detected RHEL/CentOS/Fedora system"
            sudo dnf install -y ffmpeg
            sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
            sudo chmod a+rx /usr/local/bin/yt-dlp
        elif [ -f /etc/arch-release ]; then
            # Arch Linux
            echo "Detected Arch Linux system"
            sudo pacman -S ffmpeg yt-dlp
        fi
    elif [ "$os_name" == "Darwin" ]; then
        # macOS
        echo "Detected macOS system"
        brew install ffmpeg yt-dlp
    fi
    
    echo "Dependencies have been installed."
}

# Check and install dependencies based on the operating system
base_dependencies=("yt-dlp" "ffmpeg")

# Function to install gifski specifically
install_gifski() {
    if [ "$os_name" == "Linux" ]; then
        if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
            echo "Installing gifski from .deb package..."
            wget https://github.com/ImageOptim/gifski/releases/download/1.32.0/gifski_1.32.0-1_amd64.deb
            sudo dpkg -i gifski_1.32.0-1_amd64.deb
            rm gifski_1.32.0-1_amd64.deb
        elif [ -f /etc/redhat-release ] || [ -f /etc/arch-release ]; then
            if ! command -v cargo &> /dev/null; then
                echo "Installing Rust..."
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
                source $HOME/.cargo/env
            fi
            cargo install gifski
        fi
    elif [ "$os_name" == "Darwin" ]; then
        brew install gifski
    fi
}

# Move missing_deps declaration to the top, after the color definitions
missing_deps=()

# Check if curl or wget is installed
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    echo "Neither curl nor wget is installed."
    missing_deps+=("curl")
fi

missing_deps=()
for dep in "${base_dependencies[@]}"
do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Dependency $dep is missing."
        missing_deps+=("$dep")
    fi
done

if [ "${#missing_deps[@]}" -ne 0 ]; then
    echo "Missing dependencies detected: ${missing_deps[*]}"
    read -p "Do you want to install them now? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        install_dependencies  # Remove args since they're not used
    else
        print_error "Cannot proceed without installing dependencies."
        exit 1
    fi
fi

# Add function to uninstall dependencies
uninstall_dependencies() {
    echo "Uninstalling dependencies..."
    
    if [ "$os_name" == "Linux" ]; then
        if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
            # Debian/Ubuntu
            echo "Detected Debian/Ubuntu system"
            command -v ffmpeg >/dev/null 2>&1 && sudo apt-get remove -y ffmpeg
            command -v yt-dlp >/dev/null 2>&1 && sudo rm -f /usr/local/bin/yt-dlp
            command -v gifski >/dev/null 2>&1 && sudo apt-get remove -y gifski
            sudo apt-get autoremove -y
        elif [ -f /etc/redhat-release ]; then
            # RHEL/CentOS/Fedora
            echo "Detected RHEL/CentOS/Fedora system"
            command -v ffmpeg >/dev/null 2>&1 && sudo dnf remove -y ffmpeg
            command -v yt-dlp >/dev/null 2>&1 && sudo rm -f /usr/local/bin/yt-dlp
            if command -v cargo &> /dev/null && command -v gifski &> /dev/null; then
                cargo uninstall gifski
            fi
        elif [ -f /etc/arch-release ]; then
            # Arch Linux
            echo "Detected Arch Linux system"
            command -v ffmpeg >/dev/null 2>&1 && sudo pacman -R ffmpeg
            command -v yt-dlp >/dev/null 2>&1 && sudo pacman -R yt-dlp
            if command -v cargo &> /dev/null && command -v gifski &> /dev/null; then
                cargo uninstall gifski
            fi
        fi
    elif [ "$os_name" == "Darwin" ]; then
        # macOS
        echo "Detected macOS system"
        command -v ffmpeg >/dev/null 2>&1 && brew uninstall ffmpeg
        command -v yt-dlp >/dev/null 2>&1 && brew uninstall yt-dlp
        command -v gifski >/dev/null 2>&1 && brew uninstall gifski
    fi
    
    # Remove config file if it exists
    if [ -f "$config_file" ]; then
        rm "$config_file"
        echo "Removed configuration file"
    fi
    
    echo "Dependencies have been uninstalled."
    exit 0
}

# Add check for uninstall flag right after the banner
if [ "$1" == "--uninstall" ]; then
    read -p "Are you sure you want to uninstall all dependencies? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        uninstall_dependencies
    else
        echo "Uninstall cancelled."
        exit 0
    fi
fi

# Add this near the top of the script, after the color definitions
config_file="$HOME/.giftube_config"

# Add this function to handle gifski preference
save_gifski_preference() {
    local preference=$1
    echo "INSTALL_GIFSKI=$preference" > "$config_file"
}

# Modify the gifski installation section
if ! command -v gifski &> /dev/null; then
    # Check if we have a saved preference
    if [ -f "$config_file" ]; then
        source "$config_file"
    fi

    # Only ask if we don't have a saved preference
    if [ -z "$INSTALL_GIFSKI" ]; then
        echo "Gifski is not installed. Gifski generally produces higher quality GIFs but requires additional installation."
        read -p "Would you like to install gifski for better quality? (y/n): " install_gifski_choice
        if [[ "$install_gifski_choice" =~ ^[Yy]$ ]]; then
            save_gifski_preference "yes"
            install_gifski
        else
            save_gifski_preference "no"
            echo "Using FFmpeg for GIF conversion. You can change this later by removing $config_file"
        fi
    elif [ "$INSTALL_GIFSKI" == "yes" ]; then
        echo "Installing gifski based on saved preference..."
        install_gifski
    else
        echo "Skipping gifski installation based on saved preference."
        echo "You can change this by removing $config_file"
    fi
fi

# Function to check if input is a number
is_number() {
    [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

# Prompt the user for input
read -p "Enter the YouTube URL: " url

read -p "Enter the start time (in seconds): " stt
if ! is_number "$stt"; then
    print_error "Start time must be a number."
    exit 1
fi

read -p "Enter the duration (in seconds): " dur
if ! is_number "$dur"; then
    print_error "Duration must be a number."
    exit 1
fi

# Prompt the user to select the resolution
echo "Select the resolution:"
echo "1. 1080p"
echo "2. 720p"
echo "3. 480p"
echo "4. 240p"
read -p "Enter your choice (1-4): " choice

if [[ ! "$choice" =~ ^[1-4]$ ]]; then
    print_error "Invalid choice. Defaulting to 720p."
    choice=2
fi

case $choice in
    1) width=1920; height=1080;;
    2) width=1280; height=720;;
    3) width=854; height=480;;
    4) width=426; height=240;;
esac

# Prompt the user to select the aspect ratio
echo "Select the aspect ratio:"
echo "1. 16:9 (Widescreen)"
echo "2. 4:3 (Standard)"
echo "3. 1:1 (Square)"
echo "4. 9:16 (Vertical Video)"
read -p "Enter your choice (1-4): " aspect_choice

if [[ ! "$aspect_choice" =~ ^[1-4]$ ]]; then
    print_error "Invalid choice. Defaulting to 16:9."
    aspect_choice=1
fi

case $aspect_choice in
    1) aspect_w=16; aspect_h=9;;
    2) aspect_w=4; aspect_h=3;;
    3) aspect_w=1; aspect_h=1;;
    4) aspect_w=9; aspect_h=16;;
esac

read -p "Enter the desired FPS (recommended: 10-30): " fps
if ! is_number "$fps"; then
    print_error "FPS must be a number."
    exit 1
fi

# Prompt the user to select the quality
echo "Select the quality:"
echo "1. High (100)"
echo "2. Medium (80)"
echo "3. Low (60)"
echo "4. Custom"
read -p "Enter your choice (1-4): " quality_choice

case $quality_choice in
    1) quality=100;;
    2) quality=80;;
    3) quality=60;;
    4) 
        read -p "Enter custom quality (1-100): " custom_quality
        if ! is_number "$custom_quality" || [ "$custom_quality" -lt 1 ] || [ "$custom_quality" -gt 100 ]; then
            print_error "Invalid quality. Defaulting to Medium (80)."
            quality=80
        else
            quality=$custom_quality
        fi
        ;;
    *)
        print_error "Invalid choice. Defaulting to Medium (80)."
        quality=80
        ;;
esac

read -p "Enter the output filename (without .gif extension): " output

# Automatically append .gif to the filename if not present
if [[ $output != *.gif ]]; then
    output="${output}.gif"
fi

# Calculate the new dimensions based on the aspect ratio
if [ $((width*aspect_h)) -gt $((height*aspect_w)) ]; then
    new_height=$height
    new_width=$(( height * aspect_w / aspect_h ))
else
    new_width=$width
    new_height=$(( width * aspect_h / aspect_w ))
fi

vname="_a.mp4"

# Download the video using yt-dlp
echo "Downloading video..."
if ! yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "$vname" "$url"; then
    print_error "Failed to download video"
    exit 1
fi

if [ ! -f "$vname" ]; then
    print_error "Video file not found after download"
    exit 1
fi

# Modified conversion section
echo "Converting video to GIF..."
if command -v gifski &> /dev/null; then
    echo "Using gifski for conversion..."
    # First extract frames at full resolution
    temp_dir=$(mktemp -d)
    if ! ffmpeg -v warning -stats -ss "$stt" -t "$dur" -i "$vname" \
        -vf "fps=$fps,scale=$new_width:$new_height:flags=lanczos" \
        "$temp_dir/frame%04d.png"; then
        print_error "Failed to extract frames"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Then use gifski to create the GIF
    if ! gifski --fps $fps --quality $quality --width $new_width --height $new_height \
        -o "$output" "$temp_dir/frame"*.png; then
        print_error "Failed to convert video to GIF using gifski"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Clean up
    rm -rf "$temp_dir"
else
    echo "Using FFmpeg for conversion..."
    # Create a temporary palette for better quality
    palette="/tmp/palette.png"
    filters="fps=$fps,scale=$new_width:$new_height:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"
    if ! ffmpeg -v warning -stats -ss "$stt" -t "$dur" -i "$vname" -vf "$filters" -y "$output"; then
        print_error "Failed to convert video to GIF using FFmpeg"
        exit 1
    fi
    rm -f "$palette"
fi

echo "Conversion complete."

# Clean up temporary files
rm -f "$vname"

echo "Process completed successfully! Your GIF is saved as '$output'."
