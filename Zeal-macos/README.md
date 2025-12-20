# Zeal for macOS

A native macOS version of Zeal, a fast, keyboard-driven launcher.

## Requirements

- macOS 14.0+
- Xcode 15.0+

## Installation

### Download

Download the latest release from [Releases](https://github.com/zeabur/zeal/releases).

### Build from Source

#### Xcode
```bash
git clone https://github.com/zeabur/zeal.git
cd zeal/Zeal-macos
open Zeal.xcodeproj
# Build and run in Xcode (⌘R)
```

#### CLI (Terminal)
You can use the included build script to build via `xcodebuild`:

```bash
cd Zeal-macos
./build.sh
```

The compiled app will be located at `./build/Build/Products/Release/Zeal.app`.

## Usage

### Basic

1. Press `⌥ Space` to open Zeal
2. Start typing to search keywords or apps
3. Press `Enter` to execute, or `Tab` to select a parameterized keyword
4. Press `Escape` to close

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `⌥ Space` | Open Zeal |
| `↑` / `↓` | Navigate results |
| `Tab` | Accept autocomplete / Select parameterized keyword |
| `Enter` | Execute selected item |
| `Backspace` | Return from parameter input (when empty) |
| `Escape` | Close Zeal |

### Adding Keywords

1. Click the Zeal icon in the menu bar
2. Select **Settings...**
3. Click **+** to add a new keyword
4. Enter:
   - **Short Name**: The trigger text (e.g., `gh`)
   - **Description**: Optional description
   - **URL**: The target URL. Use `{param}` for parameters (e.g., `https://github.com/{param}`)

### Example Keywords

| Shortcut | URL | Description |
|----------|-----|-------------|
| `gh` | `https://github.com/{param}` | Open GitHub user/repo |
| `g` | `https://google.com/search?q={param}` | Google search |
| `yt` | `https://youtube.com/results?search_query={param}` | YouTube search |
| `tw` | `https://twitter.com/{param}` | Open Twitter profile |
| `npm` | `https://npmjs.com/package/{param}` | Search npm package |

## Configuration

Keywords are stored in:
```
~/Library/Application Support/Zeal/keywords.json
```

You can export/import keywords from the Settings panel.

## Dependencies

- [HotKey](https://github.com/soffes/HotKey) - Global keyboard shortcuts

## Documentation

- [App Intents & System Integration](docs/AppIntents.md) - Planned features for Shortcuts, Siri, and Spotlight.
