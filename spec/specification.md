# Zeal Functional Specification

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

## 3. Feature Logic

### 3.1 Keyword Search
- **Trigger-based**: Users type a defined "short key" (e.g., `gh`) to target a specific service.
- **Parameter Support**: Keywords must support dynamic parameters.
  - *Input*: `gh zeal`
  - *Logic*: Replaces `{param}` in the stored URL `https://github.com/{param}`.
  - *Output*: Opens `https://github.com/zeal` in the default browser.
- **Default Behavior**: If the input does not match a keyword, it should fall back to a default search engine (e.g., Google or Application Search).

### 3.2 Navigation & Interaction
- **Keyboard Only**: The entire flow must be navigable without a mouse.
  - **Autocomplete**: Pressing `Tab` should autocomplete a matched keyword or confirm the selection.
  - **Execution**: Pressing `Enter` triggers the action.
  - **Selection**: Arrow keys (`↑`/`↓`) navigate results if multiple matches exist.

### 3.3 Notification & Monitoring
To support "Zeabur Management," the app acts as a monitoring agent.
- **Polling Strategy**: The app periodically checks the status of active Zeabur deployments (e.g., every 60 seconds).
- **Triggers**: Notifications are sent when:
  - A deployment status changes (e.g., `Building` -> `Success` or `Failed`).
  - A project resource limit is approached.
- **Display**: Uses the native OS notification system (e.g., macOS UserNotifications, Windows Toast) to alert the user without stealing focus.

### 3.4 Desktop Widgets
To provide "at-a-glance" status without opening the app:
- **Status Widgets**: Native widgets (macOS Notification Center/Desktop, Windows Widgets) that display the health of key Zeabur services.
- **Data Source**: Widgets share the same configuration and auth state as the main app but may poll independently (OS-managed refresh rates).
- **Actions**: Clicking a widget deep-links into the main Zeal app or opens the specific project URL.

## 4. Data Contract

### 4.1 Authentication
Zeal uses the **Zeabur Public API** to fetch project and service data.
- **Method**: API Key (Bearer Token).
- **Storage**: The API Key must be stored securely using the platform's native secure storage (e.g., **Keychain** on macOS, **Credential Locker** on Windows).
- **Configuration**:
  - The user provides the API key in the Settings panel.
  - The app validates the key by making a simple query (e.g., `me` or `projects`) before saving.
- **Scope**: The API key grants access to the user's projects, services, and deployments, which is required for:
  - Autocompleting project names.
  - Monitoring deployment status.
  - Fetching logs (future feature).

### 4.2 Configuration
The application relies on a simple configuration file to define keywords. This file should be portable across platforms.

**Schema Structure**:
- **Key**: The short trigger text (e.g., `YT`).
- **Name**: Human-readable name (e.g., `YouTube`).
- **URL**: The destination URL with an optional `{param}` placeholder.
- **Icon**: (Optional) Path or name of an icon to display.

### 4.2 Application State
- The app should respect the user's OS theme (Dark/Light mode).
- It should remember the last used position only if not using fixed smart positioning.
