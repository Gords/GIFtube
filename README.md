# GIFtube
## Youtube to GIF Converter

This Bash script allows you to convert a YouTube video to a high-quality GIF file with a specified resolution, frame rate, start time, and duration. It utilizes various tools such as `yt-dlp`, `ffmpeg`, and `gifsicle` to accomplish this task. This script is based on a previous version by [fushime2](https://github.com/fushime2/youtube-to-gif) with some quality-of-life improvements added.

![alt text](demo.gif)

## Dependencies

- `yt-dlp` (for downloading YouTube videos)
- `ffmpeg` (for video processing and GIF generation)
- `gifsicle` (for optimizing the generated GIF)

The script will attempt to install these dependencies automatically if they are not already present on your system (only in Ubuntu/Debian or macOS).

## Usage

1. Save the script 
2. Run the script with `./make_gif.sh`.
3. Enter the YouTube URL when prompted.
4. Enter the desired frames per second (FPS) for the GIF. A value between 10-30 is recommended.
5. Enter the start time (in seconds) for the video clip.
6. Enter the duration (in seconds) for the video clip.
7. Enter the desired output filename for the GIF.
8. Select the resolution for the GIF (1080p, 720p, 480p, or 240p).

The script will then download the video, generate a color palette, convert the specified video clip to a GIF using the selected resolution and FPS, and optimize the GIF file for better compression.

## License

This script is released under the [MIT License](https://opensource.org/licenses/MIT).
