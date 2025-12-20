# Zeal

A fast, keyboard-driven launcher. Quickly search and open your custom URL shortcuts and applications with a single hotkey.

![Zeal Screenshot](assets/screenshot.png)

## Features

- **Custom Keywords** - Create shortcuts with parameterized URLs (e.g., `gh {param}` → `https://github.com/{param}`)
- **App Search** - Search and launch installed applications like Spotlight
- **Autocomplete** - Predictive text hints as you type
- **Keyboard-First** - Navigate entirely with keyboard shortcuts
- **Global Hotkey** - Access from anywhere (customizable)
- **Lightweight** - Native minimal resource usage

## Platforms

### macOS
The native macOS application is located in `Zeal-macos`.
See [Zeal-macos/README.md](Zeal-macos/README.md) for installation and usage instructions.

### Windows
The Windows application is currently in development in `Zeal-windows`.
See [Zeal-windows/README.md](Zeal-windows/README.md) for more details.

## Development

### Project Structure

```
Zeal/
├── assets/                 # Shared assets
├── configs/                # Shared configurations
│   ├── default-keywords.sample.json
│   └── zeabur-admin-keyword.json (private)
├── Zeal-macos/             # macOS Native App
│   ├── Zeal.xcodeproj
│   └── Zeal/
├── Zeal-windows/           # Windows Native App (Coming Soon)
└── README.md
```

## License

MIT License © [Zeabur](https://zeabur.com)
