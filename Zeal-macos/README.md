# Zeal for macOS

A native macOS version of Zeal, a fast, keyboard-driven launcher.

## Requirements

- macOS 14.0+
- Xcode 15.0+

## Development

User documentation has been moved to the [Root README](../README.md). This document focuses on building from source.

### Build from Source

#### Xcode
```bash
git clone https://github.com/zeabur/zeal.git
cd zeal/Zeal-macos
open Zeal.xcodeproj
# Build and run in Xcode (⌘R)
```

#### CLI (Terminal)
You can use the included `Makefile` to simplify development tasks:

```bash
cd Zeal-macos

# Build the application
make build

# Build and run the app
make run

# Build and run in terminal (for debug logs)
make dev

# Clean build artifacts
make clean

# Install to /Applications
make install
```

The compiled app will be located at `./build/Build/Products/Release/Zeal.app`.

## Dependencies

- [HotKey](https://github.com/soffes/HotKey) - Global keyboard shortcuts

## Documentation

- [App Intents & System Integration](docs/AppIntents.md) - Planned features for Shortcuts, Siri, and Spotlight.
