# GIFtube
## YouTube to GIF Converter

Bash script to convert a YouTube video to a high-quality GIF file with a specified resolution, frame rate, start time, duration, and aspect ratio. Using `yt-dlp` and `ffmpeg`.

![Berserk (1997). © Kentaro Miura, Hakusensha / VAP • NTV](demo.gif)

## Features

- Download YouTube videos and convert to high-quality GIFs
- Customizable resolution, frame rate, and aspect ratio (16:9, 4:3, 1:1, or 9:16)
- Automatic installation of missing dependencies
- Easy uninstall of dependencies

## Dependencies

- `yt-dlp` (for downloading YouTube videos)
- `ffmpeg` (for video processing)

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
   - Output filename

### Uninstalling
`./make_gif.sh --uninstall`
- Removes installed dependencies

## License

[MIT License](https://opensource.org/licenses/MIT)
