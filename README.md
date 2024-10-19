# GIFtube
## YouTube to GIF Converter

Bash script to convert a YouTube video to a high-quality GIF file with a specified resolution, frame rate, start time, duration, aspect ratio, and quality. It utilizes `yt-dlp`, `ffmpeg`, and `gifski` to accomplish this task efficiently.

![alt text](demo.gif)

## Features

- Download YouTube videos
- Convert video clips to high-quality GIFs
- Customizable resolution and frame rate
- Selectable aspect ratio (16:9, 4:3, 1:1, or 9:16)
- Adjustable quality settings
- Direct conversion from video to GIF without intermediate files
- Automatic installation of missing dependencies

## Dependencies

- `yt-dlp` (for downloading YouTube videos)
- `ffmpeg` (for video processing)
- `gifski` (for high-quality GIF generation)

The script automatically checks for missing dependencies and offers to install them on supported systems (Ubuntu/Debian, Fedora/Red Hat, Arch Linux, and macOS with Homebrew). If you prefer to install them manually or are using an unsupported system, please install the dependencies before running the script.

## Usage

1. Save the script 
2. Run the script with `./make_gif.sh` (or `sudo ./make_gif.sh` on Linux if it is your first time running it and you want the dependencies to be automatically installed).
3. Follow the onscreen prompts

The script will guide you through the following steps:
- Enter the YouTube URL
- Set the start time and duration for the GIF
- Choose the output resolution
- Select the aspect ratio
- Specify the desired FPS (frames per second)
- Choose the quality setting (High, Medium, Low, or Custom)
- Enter the output filename

The script will then download the video and convert it directly to a high-quality GIF using the selected parameters.

## Quality Settings

- High: 100 (Best quality, largest file size)
- Medium: 80 (Good balance between quality and file size)
- Low: 60 (Smaller file size, lower quality)
- Custom: 1-100 (User-defined, higher values mean better quality but larger file size)

## License

This script is released under the [MIT License](https://opensource.org/licenses/MIT)
