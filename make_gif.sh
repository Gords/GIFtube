#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Color definitions
green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

# Function to display the banner
show_banner() {
    echo -e "${green}
8''''8 8  8'''' ''8'' 8   8 8''''8   8''''
8    ' 8  8       8   8   8 8    8   8
8e     8e 8eeee   8e  8e  8 8eeee8ee 8eeee
88  ee 88 88      88  88  8 88     8 88
88   8 88 88      88  88  8 88     8 88
88eee8 88 88      88  88ee8 88eeeee8 88eee
${reset}"
}

# Function to print error messages
print_error() {
    echo -e "${red}Error: $1${reset}" >&2
}

# Function to install dependencies
install_dependencies() {
    echo "Installing dependencies..."

    # Detect the operating system
    os_name=$(uname)

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

# Function to check and install dependencies
check_and_install_dependencies() {
    missing_deps=()
    for dep in "yt-dlp" "ffmpeg"
    do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done

    if [ "${#missing_deps[@]}" -ne 0 ]; then
        echo "Missing dependencies detected: ${missing_deps[*]}"
        read -rp "Do you want to install them now? (y/n): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            install_dependencies
        else
            print_error "Cannot proceed without installing dependencies."
            exit 1
        fi
    fi
}

# Function to uninstall dependencies
uninstall_dependencies() {
    echo "Uninstalling dependencies..."

    # Detect the operating system
    os_name=$(uname)

    if [ "$os_name" == "Linux" ]; then
        if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
            echo "Detected Debian/Ubuntu system"
            command -v ffmpeg >/dev/null 2>&1 && sudo apt-get remove -y ffmpeg
            command -v yt-dlp >/dev/null 2>&1 && sudo rm -f /usr/local/bin/yt-dlp
            sudo apt-get autoremove -y
        elif [ -f /etc/redhat-release ]; then
            echo "Detected RHEL/CentOS/Fedora system"
            command -v ffmpeg >/dev/null 2>&1 && sudo dnf remove -y ffmpeg
            command -v yt-dlp >/dev/null 2>&1 && sudo rm -f /usr/local/bin/yt-dlp
        elif [ -f /etc/arch-release ]; then
            echo "Detected Arch Linux system"
            command -v ffmpeg >/dev/null 2>&1 && sudo pacman -R ffmpeg
            command -v yt-dlp >/dev/null 2>&1 && sudo pacman -R yt-dlp
        fi
    elif [ "$os_name" == "Darwin" ]; then
        echo "Detected macOS system"
        command -v ffmpeg >/dev/null 2>&1 && brew uninstall ffmpeg
        command -v yt-dlp >/dev/null 2>&1 && brew uninstall yt-dlp
    fi

    echo "Dependencies have been uninstalled."
}

# Function to handle the uninstall flag
handle_uninstall() {
    read -rp "Are you sure you want to uninstall all dependencies? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        uninstall_dependencies
    else
        echo "Uninstall cancelled."
    fi
}

# Function to validate number input
is_number() {
    [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

# Function to get validated input
get_validated_input() {
    local prompt=$1
    local validation_type=$2
    local default_value=$3
    local error_msg=$4

    while true; do
        read -rp "$prompt" input

        # Use default if empty
        if [ -z "$input" ] && [ -n "$default_value" ]; then
            echo "$default_value"
            return
        fi

        # Validate input
        case $validation_type in
            "number")
                if is_number "$input"; then
                    echo "$input"
                    return
                fi
                ;;
            "choice")
                if [[ "$input" =~ ^[1-4]$ ]]; then
                    echo "$input"
                    return
                fi
                ;;
            *)
                echo "$input"
                return
                ;;
        esac

        print_error "$error_msg"
    done
}

# Function to collect all user inputs
collect_user_inputs() {
    # Get URL
    read -rp "Enter the YouTube URL: " url
    while [ -z "$url" ]; do
        print_error "URL cannot be empty."
        read -rp "Enter the YouTube URL: " url
    done

    # Get time values
    stt=$(get_validated_input "Enter the start time (in seconds): " "number" "" "Start time must be a number.")
    dur=$(get_validated_input "Enter the duration (in seconds): " "number" "" "Duration must be a number.")

    # Get resolution
    echo "Select the resolution:"
    echo "1. 1080p"
    echo "2. 720p"
    echo "3. 480p"
    echo "4. 240p"
    choice=$(get_validated_input "Enter your choice (1-4): " "choice" "2" "Invalid choice. Please enter 1-4 or press Enter for 720p.")

    # Set resolution values
    case $choice in
        1) width=1920; height=1080;;
        2) width=1280; height=720;;
        3) width=854; height=480;;
        4) width=426; height=240;;
    esac

    # Get aspect ratio
    echo "Select the aspect ratio:"
    echo "1. 16:9 (Widescreen)"
    echo "2. 4:3 (Standard)"
    echo "3. 1:1 (Square)"
    echo "4. 9:16 (Vertical Video)"
    aspect_choice=$(get_validated_input "Enter your choice (1-4): " "choice" "1" "Invalid choice. Please enter 1-4 or press Enter for 16:9.")

    # Set aspect ratio values
    case $aspect_choice in
        1) aspect_w=16; aspect_h=9;;
        2) aspect_w=4; aspect_h=3;;
        3) aspect_w=1; aspect_h=1;;
        4) aspect_w=9; aspect_h=16;;
    esac

    # Get FPS
    fps=$(get_validated_input "Enter the desired FPS (recommended: 10-30): " "number" "" "FPS must be a number.")

    # Get output filename
    read -rp "Enter the output filename (without .gif extension): " output
    while [ -z "$output" ]; do
        print_error "Filename cannot be empty."
        read -rp "Enter the output filename (without .gif extension): " output
    done

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
}

# Function to convert video to GIF using ffmpeg
convert_video_to_gif() {
    local input_video="$1"
    local output_gif="$2"
    local start_time="$3"
    local duration="$4"
    local fps="$5"
    local width="$6"
    local height="$7"

    echo "Converting video to GIF..."

    filters="fps=$fps,scale=$width:$height:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"
    if ! ffmpeg -v warning -stats -ss "$start_time" -t "$duration" -i "$input_video" -vf "$filters" -y "$output_gif"; then
        print_error "Failed to convert video to GIF"
        return 1
    fi

    echo "Conversion complete."
}

# Main function
main() {
    # Display banner
    show_banner

    # Handle uninstall flag
    if [ "$1" == "--uninstall" ]; then
        handle_uninstall
        exit 0
    fi

    # Check and install dependencies
    check_and_install_dependencies

    # Collect user inputs
    collect_user_inputs

    # Download video
    echo "Downloading video..."
    vname=$(mktemp "${TMPDIR:-/tmp}/giftube_video.XXXXXX")
    rm -f "$vname"
    vname="$vname.mp4"
    trap 'rm -f "$vname"' EXIT
    if ! yt-dlp -f "bestvideo[ext=mp4]/best[ext=mp4]/best" -o "$vname" -- "$url"; then
        print_error "Failed to download video"
        exit 1
    fi

    if [ ! -f "$vname" ]; then
        print_error "Video file not found after download"
        exit 1
    fi

    # Convert video to GIF
    convert_video_to_gif "$vname" "$output" "$stt" "$dur" "$fps" "$new_width" "$new_height"

    echo "Process completed successfully! Your GIF is saved as '$output'."
}

# Call main function with all arguments
main "$@"
