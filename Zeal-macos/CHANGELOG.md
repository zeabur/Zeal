# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Scripts**: Added `run.sh`, `close.sh`, and `open.sh` for improved development workflow.
- **Documentation**: Added `docs/AppIntents.md` outlining planned Shortcuts, Siri, and Spotlight integrations.
- **UX**: Implemented "Close on Blur" behavior (window closes when losing focus).
- **UX**: Smart window positioning (appears on the screen with the mouse cursor, positioned ~20% from the top).
- **Feature**: Toggle visibility with hotkey (opens if closed, closes if open).

### Changed
- **Build**: Updated `build.sh` to support local ad-hoc signing (fixes "Launch failed" error 163) and filter log output.
- **UI**: Changed window style to `.borderless` to fix focus issues and match Spotlight behavior.
- **Refactor**: Applied "Tidy First" principles:
    - Extracted `KeyablePanel`, `SettingsComponents`, and `Key+Description` into separate files.
    - Implemented dependency injection in `SearchViewModel`.
    - Integrated new files into `project.pbxproj`.

### Fixed
- **Focus**: Fixed issue where the search field was not focused immediately upon opening.
- **Positioning**: Fixed issue where window position drifted or retained previous size on re-open.
- **Build**: Fixed `xcodebuild` warnings regarding missing destination.
