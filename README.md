# GIFtube
## Youtube to GIF Converter

Bash script to convert a YouTube video to a high-quality GIF file with a specified resolution, frame rate, start time, and duration. It utilizes `yt-dlp`, `ffmpeg`, and `gifsicle` to accomplish this task. This script is based on a previous version by [fushime2](https://github.com/fushime2/youtube-to-gif) with updated and new libraries, optimization and some other quality-of-life improvements added.

![alt text](demo.gif)

## Dependencies

- `yt-dlp` (for downloading YouTube videos)
- `ffmpeg` (for video processing and GIF generation)
- `gifsicle` (for optimizing the generated GIF)

The script will attempt to automatically install these dependencies if they are not already present on your system. It only supports automatic installation on Ubuntu/Debian and macOS; on other operating systems, you will need to install the dependencies manually.

## Usage

1. Save the script 
2. Run the script with `./make_gif.sh`
3. Follow the onscreen prompts

The script will then download the video, generate a color palette, convert the specified video clip to a GIF using the selected resolution and FPS, and optimize the GIF file for better compression.

## License

This script is released under the [MIT License](https://opensource.org/licenses/MIT).
