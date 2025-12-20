# Monitoring & Widgets

## 1. Notification & Monitoring
To support "Zeabur Management," the app acts as a monitoring agent.

- **Polling Strategy**: The app periodically checks the status of active Zeabur deployments (e.g., every 60 seconds).
- **Triggers**: Notifications are sent when:
  - A deployment status changes (e.g., `Building` -> `Success` or `Failed`).
  - A project resource limit is approached.
- **Display**: Uses the native OS notification system (e.g., macOS UserNotifications, Windows Toast) to alert the user without stealing focus.

## 2. Desktop Widgets
To provide "at-a-glance" status without opening the app:

- **Status Widgets**: Native widgets (macOS Notification Center/Desktop, Windows Widgets) that display the health of key Zeabur services.
- **Data Source**: Widgets share the same configuration and auth state as the main app but may poll independently (OS-managed refresh rates).
- **Actions**: Clicking a widget deep-links into the main Zeal app or opens the specific project URL.
