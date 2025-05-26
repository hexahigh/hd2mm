# HD2MM
A version 2 of the [Helldivers 2 Mod Manager](https://github.com/teutinsa/Helldivers2ModManager).
What stared as a utility now has evolved to be a comprehensive tool for managing mods for the game Helldivers 2 with many features.

## Usage
Simply run `Helldivers2ModManager.exe` or `hd2mm` depending on your platform.
If you want `rar` and `7z` files to be supported you need to have either `7zip` or `unrar` installed.

## Building
Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
Create a `.env` file that has these fields filled in:
```ini
# GitHub API token that has read permissions for the repos contents for acquiring update information
GITHUB_TOKEN=
```

### Windows
Run `build.bat`.

### Linux
Install `zenity` which is a dependency for file browsing.
```bash
sudo apt install zenity -y
```
Run `build.sh`.