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

# Detect the operating system
os_name=$(uname)

# Check and install dependencies based on the operating system
dependencies=("yt-dlp" "ffmpeg" "gifsicle")

install_dependencies() {
    if [ "$os_name" == "Linux" ]; then
        # Check for Debian/Ubuntu-based systems
        if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
            sudo apt-get update
            sudo apt-get install -y "${dependencies[@]}"
        # Check for Fedora/Red Hat-based systems
        elif [ -f /etc/redhat-release ]; then
            sudo dnf install -y "${dependencies[@]}"
        else
            print_error "Unsupported Linux distribution"
            exit 1
        fi
    elif [ "$os_name" == "Darwin" ]; then
        # For macOS using Homebrew
        brew update
        brew install "${dependencies[@]}"
    else
        print_error "Unsupported operating system: $os_name"
        exit 1
    fi
}

for dep in "${dependencies[@]}"
do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Installing $dep..."
        install_dependencies
        break
    fi
done

# Prompt the user for input
read -p "Enter the YouTube URL: " url
read -p "Enter the desired FPS (recommended: 10-30): " fps
read -p "Enter the start time (in seconds): " stt
read -p "Enter the duration (in seconds): " dur
read -p "Enter the output filename (without .gif extension): " output

# Automatically append .gif to the filename if not present
if [[ $output != *.gif ]]; then
    output="${output}.gif"
fi

# Prompt the user to select the resolution
echo "Select the resolution:"
echo "1. 1080p"
echo "2. 720p"
echo "3. 480p"
echo "4. 240p"
read -p "Enter your choice (1-4): " choice

case $choice in
    1) width=1920; height=1080;;
    2) width=1280; height=720;;
    3) width=854; height=480;;
    4) width=426; height=240;;
    *) echo "Invalid choice. Defaulting to 720p."; width=1280; height=720;;
esac

# Prompt the user to select the aspect ratio
echo "Select the aspect ratio:"
echo "1. 16:9 (Widescreen)"
echo "2. 4:3 (Standard)"
echo "3. 1:1 (Square)"
echo "4. 9:16 (Vertical Video)"
read -p "Enter your choice (1-4): " aspect_choice

case $aspect_choice in
    1) aspect_w=16; aspect_h=9;;
    2) aspect_w=4; aspect_h=3;;
    3) aspect_w=1; aspect_h=1;;
    4) aspect_w=9; aspect_h=16;;
    *) echo "Invalid choice. Defaulting to 16:9."; aspect_w=16; aspect_h=9;;
esac

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

# Generate color palette
echo "Generating color palette..."
palette="_palette.png"
if ! ffmpeg -v warning -stats -hwaccel auto -ss "$stt" -t "$dur" -i "$vname" -vf "fps=$fps,scale=$new_width:$new_height:flags=lanczos,palettegen=max_colors=256:stats_mode=full" -y "$palette" 2>/dev/null; then
    print_error "Failed to generate color palette"
    exit 1
fi

if [ ! -f "$palette" ]; then
    print_error "Palette file not found after generation"
    exit 1
fi

# Convert the video to GIF using the generated palette
echo "Converting video to GIF..."
if ! ffmpeg -v warning -stats -hwaccel auto -ss "$stt" -t "$dur" -i "$vname" -i "$palette" -lavfi "fps=$fps,scale=$new_width:$new_height:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" -y "$output" 2>/dev/null; then
    print_error "Failed to convert video to GIF"
    exit 1
fi

# Optimize the GIF using gifsicle with a progress indicator
echo "Optimizing GIF..."
if ! gifsicle -O3 --lossy=80 -o "optimized_$output" "$output"; then
    print_error "Failed to optimize GIF"
    exit 1
fi

echo "Optimization complete."

# Clean up temporary files
rm -f "$vname"
rm -f "$palette"

echo "Process completed successfully! Your GIF is saved as 'optimized_$output'."