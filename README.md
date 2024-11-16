# GIFtube
## YouTube to GIF Converter

Bash script to convert a YouTube video to a high-quality GIF file with a specified resolution, frame rate, start time, duration, aspect ratio, and quality. It utilizes `yt-dlp`, `ffmpeg`, and optionally `gifski`.

![Berserk (1997). © Kentaro Miura, Hakusensha / VAP • NTV](demo.gif)

## Features

- Download YouTube videos and convert to high-quality GIFs
- Customizable resolution, frame rate, and aspect ratio (16:9, 4:3, 1:1, or 9:16)
- Adjustable quality settings
- Automatic installation of missing dependencies
- Saves user preferences for conversion method
- Easy uninstall of dependencies

## Dependencies

### Required
- `yt-dlp` (for downloading YouTube videos)
- `ffmpeg` (for video processing)

### Optional
- `gifski` (for higher quality GIF generation)

The script automatically checks for missing dependencies and offers to install them on supported systems:
- Ubuntu/Debian: Uses apt-get for ffmpeg and installs yt-dlp binary directly
- Fedora/Red Hat: Uses dnf for ffmpeg and installs yt-dlp binary directly
- Arch Linux: Uses pacman
- macOS: Uses Homebrew

## Usage

1. Make the script executable: `chmod +x make_gif.sh`
2. Run: `./make_gif.sh` (or `sudo ./make_gif.sh` on Linux for first-time installation)
3. Follow the prompts to specify:
   - YouTube URL
   - Start time and duration
   - Resolution and aspect ratio
   - FPS (frames per second)
   - Quality setting (High: 100, Medium: 80, Low: 60, or Custom: 1-100)
   - Output filename

### Uninstalling
`./make_gif.sh --uninstall`
- Removes all dependencies and configuration files

### Conversion Methods

1. **FFmpeg** (Default)
   - Faster conversion
   - Smaller file sizes
   - Uses palette generation

2. **Gifski** (Optional)
   - Higher quality output
   - Better color preservation
   - Slower conversion

Your preference for gifski is saved and can be changed by:
- Running the uninstall command and reinstalling
- Removing the `.giftube_config` file

## License

[MIT License](https://opensource.org/licenses/MIT)
