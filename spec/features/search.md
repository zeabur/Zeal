# Search & Navigation

## 1. Keyword Search
- **Trigger-based**: Users type a defined "short key" (e.g., `gh`) to target a specific service.
- **Parameter Support**: Keywords must support dynamic parameters.
  - *Input*: `gh zeal`
  - *Logic*: Replaces `{param}` in the stored URL `https://github.com/{param}`.
  - *Output*: Opens `https://github.com/zeal` in the default browser.
- **Default Behavior**: If the input does not match a keyword, it should fall back to a default search engine (e.g., Google or Application Search).

## 2. Navigation & Interaction
- **Keyboard Only**: The entire flow must be navigable without a mouse.
  - **Autocomplete**: Pressing `Tab` should autocomplete a matched keyword or confirm the selection.
  - **Execution**: Pressing `Enter` triggers the action.
  - **Selection**: Arrow keys (`↑`/`↓`) navigate results if multiple matches exist.

## 3. Configuration
The application relies on a simple configuration file to define keywords. This file should be portable across platforms.

**Schema Structure**:
- **Key**: The short trigger text (e.g., `YT`).
- **Name**: Human-readable name (e.g., `YouTube`).
- **URL**: The destination URL with an optional `{param}` placeholder.
- **Icon**: (Optional) Path or name of an icon to display.
