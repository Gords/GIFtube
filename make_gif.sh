#!/bin/bash

green='\033[0;32m'
reset='\033[0m'

echo -e "${green}
8''''8 8  8'''' ''8'' 8   8 8''''8   8'''' 
8    ' 8  8       8   8   8 8    8   8     
8e     8e 8eeee   8e  8e  8 8eeee8ee 8eeee 
88  ee 88 88      88  88  8 88     8 88    
88   8 88 88      88  88  8 88     8 88    
88eee8 88 88      88  88ee8 88eeeee8 88eee 
${reset}"

# Detect the operating system
os_name=$(uname)

# Check and install dependencies based on the operating system
dependencies=("yt-dlp" "ffmpeg" "gifsicle")

install_dependencies() {
    if [ "$os_name" == "Linux" ]; then
        # Check for Debian/Ubuntu-based systems
        if [ -f /etc/debian_version ]; then
            sudo apt-get update
            sudo apt-get install -y "${dependencies[@]}"
        # Check for Fedora/Red Hat-based systems
        elif [ -f /etc/redhat-release ]; then
            sudo dnf install -y "${dependencies[@]}"
        else
            echo "Unsupported Linux distribution"
            exit 1
        fi
    elif [ "$os_name" == "Darwin" ]; then
        # For macOS using Homebrew
        brew update
        brew install "${dependencies[@]}"
    else
        echo "Unsupported operating system: $os_name"
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
read -p "Enter the output filename: " output

# Prompt the user to select the resolution
echo "Select the resolution:"
echo "1. 1080p"
echo "2. 720p"
echo "3. 480p"
echo "4. 240p"
read -p "Enter your choice (1-4): " choice

case $choice in
    1) size="1920:-1";;
    2) size="1280:-1";;
    3) size="854:-1";;
    4) size="426:-1";;
    *) echo "Invalid choice. Defaulting to 720p."; size="1280:-1";;
esac

vname="_a.mp4"

# Download the video using yt-dlp
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "$vname" "$url"

# Generate color palette
palette="_palette.png"
ffmpeg -loglevel warning -ss "$stt" -t "$dur" -y -i "$vname" -vf "fps=$fps,scale=$size:flags=lanczos,format=rgb24,palettegen=max_colors=256" "$palette" >/dev/null 2>&1

# Convert the video to GIF using the generated palette
ffmpeg -loglevel warning -ss "$stt" -t "$dur" -y -i "$vname" -i "$palette" -lavfi "fps=$fps,scale=$size:flags=lanczos [x]; [x][1:v] paletteuse" "$output"

# Optimize the GIF using gifsicle with a progress indicator
echo "Optimizing GIF..."
gifsicle -O3 --lossy=80 -o "optimized_$output" "$output" &
pid=$!

while kill -0 $pid 2>/dev/null; do
    echo -n "."
    sleep 1
done
echo ""
echo "Optimization complete."

# Clean up temporary files
rm "$vname"
rm "$palette" add more operating systems support
