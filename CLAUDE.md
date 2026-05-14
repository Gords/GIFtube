# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GIFtube is a single-file Bash script (`make_gif.sh`) that downloads YouTube videos via `yt-dlp` and converts them to GIFs using `ffmpeg` with palette-based encoding. Fully interactive — all parameters are collected via prompts at runtime.

## Running

```bash
./make_gif.sh              # interactive GIF creation
./make_gif.sh --uninstall  # remove installed dependencies
```

No build step, no tests, no linter. The script is the entire project.

## Dependencies

- **Required:** `yt-dlp`, `ffmpeg`

The script auto-detects the OS (Debian/Ubuntu, RHEL/Fedora, Arch, macOS) and offers to install missing deps.

## Architecture (make_gif.sh)

The script flows linearly through `main()`:

1. **Banner** → `show_banner()`
2. **Dep check** → `check_and_install_dependencies()` — checks for `yt-dlp` and `ffmpeg`, offers per-OS installation if missing
3. **Input collection** → `collect_user_inputs()` — URL, start time, duration, resolution (1080/720/480/240), aspect ratio (16:9/4:3/1:1/9:16), FPS, output filename. Dimensions are recalculated to fit the chosen aspect ratio.
4. **Download** → `yt-dlp` fetches best mp4 to `_a.mp4`
5. **Conversion** → `convert_video_to_gif()` — single-pass ffmpeg with `palettegen`/`paletteuse` split/merge filtergraph for quality
6. **Cleanup** → removes downloaded video

Key details:
- `set -e` is active — any command failure exits the script.
- Input validation uses `get_validated_input()` which loops until valid input is provided.
