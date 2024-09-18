# GIFtube
## Youtube to GIF Converter

Bash script to convert a YouTube video to a high-quality GIF file with a specified resolution, frame rate, start time, duration, and aspect ratio. It utilizes `yt-dlp`, `ffmpeg`, and `gifsicle` to accomplish this task.

![alt text](demo.gif)

## Features

- Download YouTube videos
- Convert video clips to high-quality GIFs
- Customizable resolution and frame rate
- Selectable aspect ratio (16:9, 4:3, 1:1, or 9:16)
- Optimized color palette generation
- GIF optimization for reduced file size
- Automatic installation of missing dependencies

## Dependencies

- `yt-dlp` (for downloading YouTube videos)
- `ffmpeg` (for video processing and GIF generation)
- `gifsicle` (for optimizing the generated GIF)

The script automatically checks for missing dependencies and offers to install them on supported systems (Ubuntu/Debian, Fedora/Red Hat, Arch Linux, and macOS with Homebrew). If you prefer to install them manually or are using an unsupported system, please install the dependencies before running the script.

## Usage

1. Save the script 
2. Run the script with `./make_gif.sh` (or `sudo ./make_gif.sh` on Linux if it is your first time running it and you want the dependencies to be automatically installed).
3. Follow the onscreen prompts

The script will guide you through the following steps:
- Enter the YouTube URL
- Specify the desired FPS (frames per second)
- Set the start time and duration for the GIF
- Choose the output resolution
- Select the aspect ratio
- Enter the output filename

The script will then download the video, generate a color palette, convert the video to GIF using the selected resolution, FPS, and aspect ratio, and optimize the GIF file for better compression.

## License

This script is released under the [MIT License](https://opensource.org/licenses/MIT)
