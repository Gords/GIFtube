# Changelog

## [Unreleased]

### Added

- **Update Functionality for yt-dlp Without pip**: Modified the `update_yt_dlp` function to download the latest `yt-dlp` binary directly from the official GitHub releases, avoiding dependency on `pip`. The script now:
  - Checks if `yt-dlp -U` can update `yt-dlp`.
  - If not, downloads the latest binary using `curl` or `wget`.
  - Installs `yt-dlp` to `/usr/local/bin` or `~/.local/bin` based on write permissions.
  - Adds the installation directory to `PATH` if it's not already included.

### Changed

- **Dependency Checks**:
  - Added checks to ensure that either `curl` or `wget` is installed, as they are necessary to download the `yt-dlp` binary.
  - Included `curl` in the list of dependencies if neither `curl` nor `wget` is found.

- **Removed pip Dependency**:
  - Removed all references to `pip` from the `update_yt_dlp` function.
  - The script no longer relies on `pip` for updating `yt-dlp`, ensuring it works in environments where `pip` is not available.

### Fixed

- **Error Handling and Messaging**:
  - Improved error messages throughout the script for better clarity and user experience.
  - Ensured consistent handling of situations where dependencies are missing or updates fail.

### Notes

- **First-Time Use**:
  - The script may modify `~/.bashrc` to add `~/.local/bin` to the `PATH`. Users may need to source `~/.bashrc` or restart their terminal session after the script runs.

- **Permissions**:
  - If the script cannot write to the installation directories due to permission issues, it prompts the user and exits gracefully.
