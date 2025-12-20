# Authentication

## 1. Zeabur Public API
Zeal uses the **Zeabur Public API** to fetch project and service data.

- **Method**: API Key (Bearer Token).
- **Storage**: The API Key must be stored securely using the platform's native secure storage (e.g., **Keychain** on macOS, **Credential Locker** on Windows).

## 2. Configuration
- The user provides the API key in the Settings panel.
- The app validates the key by making a simple query (e.g., `me` or `projects`) before saving.

## 3. Scope
The API key grants access to the user's projects, services, and deployments, which is required for:
- Autocompleting project names.
- Monitoring deployment status.
- Fetching logs (future feature).
