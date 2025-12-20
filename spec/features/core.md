# Core Specification

## 1. Product Overview
Zeal is a keyboard-centric launcher optimized for managing Zeabur services and resources. While it supports general-purpose keywords, its primary mission is to provide valid and swift shortcuts for Zeabur dashboard operations, deployments, and documentation.

## 2. Core Behavior

### 2.1 Activation & Visibility
- **Global Access**: The application runs in the background and is activated via a global hotkey (e.g., `Alt+Space` or `Option+Space`).
- **Instant Focus**: Upon activation, the application window must appear immediately and the search input field must capture keyboard focus.
- **Transient Nature**: The window should automatically close (hide) when:
  - The user presses the `Escape` key.
  - The window loses focus (user clicks elsewhere or switches apps).
  - An action is executed.

### 2.2 Window Design
- **Minimalist**: A simple, borderless search bar.
- **Positioning**: The window should appear in a prominent, ergonomic position on the active screen (typically centered horizontally, slightly above the vertical center).

## 3. Application State
- The app should respect the user's OS theme (Dark/Light mode).
- It should remember the last used position only if not using fixed smart positioning.
