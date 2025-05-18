# HD2MM
A version 2 of the [Helldivers 2 Mod Manager](https://github.com/teutinsa/Helldivers2ModManager).
What stared as a utility now has evolved to be a comprehensive tool for managing mods for the game Helldivers 2 with many features.

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
Run `build.sh`.