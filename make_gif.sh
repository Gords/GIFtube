#!/bin/bash

# Configuration
green='\033[0;32m'
reset='\033[0m'
dependencies=("yt-dlp" "ffmpeg" "gifsicle")
config_file="$HOME/.gif_maker_config"

# ASCII art logo
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
install_dependencies() {
    case "$os_name" in
        Linux)
            # For Ubuntu/Debian systems
            sudo apt-get update
            sudo apt-get install -y "${dependencies[@]}"
            ;;
        Darwin)
            # For macOS using Homebrew
            brew update
            brew install "${dependencies[@]}"
            ;;
        *)
            echo "Unsupported operating system: $os_name"
            exit 1
            ;;
    esac
}

# Check for missing dependencies and install them
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Installing $dep..."
        install_dependencies
        break
    fi
done

# Load or create configuration
if [ -f "$config_file" ]; then
    source "$config_file"
else
    echo "fps=15" > "$config_file"
    echo "size=1280:-1" >> "$config_file"
fi

# Prompt the user for input
read -p "Enter the YouTube URL: " url
read -p "Enter the desired FPS (recommended: 10-30): " fps
read -p "Enter the start time (in seconds): " stt
read -p "Enter the duration (in seconds): " dur
read -p "Enter the output filename: " output

# Select the resolution
echo "Select the resolution:"
select choice in "1080p" "720p" "480p" "240p"; do
    case $choice in
        "1080p") size="1920:-1"; break;;
        "720p") size="1280:-1"; break;;
        "480p") size="854:-1"; break;;
        "240p") size="426:-1"; break;;
        *) echo "Invalid choice. Defaulting to 720p."; size="1280:-1";;
    esac
done

vname="_a.mp4"

# Download the video using yt-dlp
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "$vname" "$url"

# Generate color palette
palette="_palette.png"
ffmpeg -loglevel warning -ss "$stt" -t "$dur" -y -i "$vname" -vf "fps=$fps,scale=$size:flags=lanczos,format=rgb24,palettegen=max_colors=256" "$palette" >/dev/null 2>&1

# Convert the video to GIF using the generated palette
ffmpeg -loglevel warning -ss "$stt" -t "$dur" -y -i "$vname" -i "$palette" -lavfi "fps=$fps,scale=$size:flags=lanczos [x]; [x][1:v] paletteuse" "$output"

# Optimize the GIF using gifsicle with a progress bar
echo "Optimizing GIF..."
gifsicle -O3 --lossy=80 -o "optimized_$output" "$output" | pv -pte -s $(du -sb "$output" | awk '{print $1}') > /dev/null

# Clean up temporary files
rm -i "$vname"
rm -i "$palette"

echo "GIF creation and optimization complete. File saved as optimized_$output"
