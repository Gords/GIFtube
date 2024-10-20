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

# Function to print error messages
print_error() {
    echo -e "${red}Error: $1${reset}"
}

# Function to update yt-dlp to the latest version without using pip
update_yt_dlp() {
    echo "Checking if yt-dlp is up to date..."
    if yt-dlp -U >/dev/null 2>&1; then
        echo "yt-dlp is up to date or has been updated."
    else
        echo "Failed to update yt-dlp using 'yt-dlp -U'. Downloading the latest release binary..."
        # Determine the correct URL for the latest release
        latest_url="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"

        # Determine installation directory
        if [ -w "/usr/local/bin" ]; then
            install_dir="/usr/local/bin"
        elif [ -w "$HOME/.local/bin" ]; then
            install_dir="$HOME/.local/bin"
            mkdir -p "$install_dir"
        else
            print_error "Cannot write to /usr/local/bin or ~/.local/bin. Please run the script with appropriate permissions."
            exit 1
        fi

        # Download the latest binary
        if command -v curl >/dev/null 2>&1; then
            if curl -L "$latest_url" -o "$install_dir/yt-dlp"; then
                chmod a+rx "$install_dir/yt-dlp"
                echo "yt-dlp has been updated and installed to $install_dir/yt-dlp."
            else
                print_error "Failed to download yt-dlp using curl."
                exit 1
            fi
        elif command -v wget >/dev/null 2>&1; then
            if wget "$latest_url" -O "$install_dir/yt-dlp"; then
                chmod a+rx "$install_dir/yt-dlp"
                echo "yt-dlp has been updated and installed to $install_dir/yt-dlp."
            else
                print_error "Failed to download yt-dlp using wget."
                exit 1
            fi
        else
            print_error "Neither curl nor wget is installed. Cannot download yt-dlp."
            exit 1
        fi

        # Add install_dir to PATH if it's not already there
        if ! echo "$PATH" | grep -q "$install_dir"; then
            export PATH="$install_dir:$PATH"
            echo "export PATH=\"$install_dir:\$PATH\"" >> "$HOME/.bashrc"
            echo "Added $install_dir to PATH."
        fi
    fi
}

# Detect the operating system
os_name=$(uname)

# Check and install dependencies based on the operating system
dependencies=("yt-dlp" "ffmpeg" "gifski")

install_dependencies() {
    deps_to_install=("$@")
    if [ "$os_name" == "Linux" ]; then
        # Check for Debian/Ubuntu-based systems
        if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
            if ! sudo -v >/dev/null 2>&1; then
                print_error "You need sudo privileges to install dependencies."
                exit 1
            fi
            sudo apt-get update
            for dep in "${deps_to_install[@]}"; do
                if [ "$dep" = "gifski" ]; then
                    if ! command -v gifski &> /dev/null; then
                        echo "Installing gifski from .deb package..."
                        wget https://github.com/ImageOptim/gifski/releases/download/1.32.0/gifski_1.32.0-1_amd64.deb
                        sudo dpkg -i gifski_1.32.0-1_amd64.deb
                        rm gifski_1.32.0-1_amd64.deb
                    fi
                else
                    sudo apt-get install -y "$dep"
                fi
            done
        # Check for Fedora/Red Hat-based systems
        elif [ -f /etc/redhat-release ]; then
            if ! sudo -v >/dev/null 2>&1; then
                print_error "You need sudo privileges to install dependencies."
                exit 1
            fi
            sudo dnf install -y "${deps_to_install[@]}"
            # Install Rust and gifski
            if ! command -v cargo &> /dev/null; then
                echo "Installing Rust..."
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
                source $HOME/.cargo/env
            fi
            cargo install gifski
        # Check for Arch-based systems
        elif [ -f /etc/arch-release ]; then
            if ! sudo -v >/dev/null 2>&1; then
                print_error "You need sudo privileges to install dependencies."
                exit 1
            fi
            sudo pacman -Sy --noconfirm "${deps_to_install[@]}"
            # Install Rust and gifski
            if ! command -v cargo &> /dev/null; then
                echo "Installing Rust..."
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
                source $HOME/.cargo/env
            fi
            cargo install gifski
        else
            print_error "Unsupported Linux distribution"
            exit 1
        fi
    elif [ "$os_name" == "Darwin" ]; then
        # For macOS using Homebrew
        if ! command -v brew >/dev/null 2>&1; then
            print_error "Homebrew is not installed. Please install Homebrew and rerun the script."
            exit 1
        fi
        brew update
        brew install "${deps_to_install[@]}"
    else
        print_error "Unsupported operating system: $os_name"
        exit 1
    fi
}

# Check if curl or wget is installed
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    echo "Neither curl nor wget is installed."
    missing_deps+=("curl")
fi

missing_deps=()
for dep in "${dependencies[@]}"
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
        install_dependencies "${missing_deps[@]}"
    else
        print_error "Cannot proceed without installing dependencies."
        exit 1
    fi
fi

# Update yt-dlp to the latest version
update_yt_dlp

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

# Convert the video to GIF using ffmpeg and gifski
echo "Converting video to GIF..."
if ! ffmpeg -v warning -stats -ss "$stt" -t "$dur" -i "$vname" -vf "fps=$fps,scale=$new_width:$new_height:flags=lanczos" -f yuv4mpegpipe - | gifski -o "$output" --fps $fps --quality $quality -; then
    print_error "Failed to convert video to GIF"
    exit 1
fi

echo "Conversion complete."

# Clean up temporary files
rm -f "$vname"

echo "Process completed successfully! Your GIF is saved as '$output'."
