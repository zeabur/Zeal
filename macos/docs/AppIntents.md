# App Intents & System Integration (Planned Features)

This document outlines potential future features leveraging Apple's **App Intents** framework. These integrations would allow Zeal to communicate deeply with the macOS system, enabling automation, voice control, and unified search.

> **Note**: These features are currently **not implemented**. This document serves as a design reference.

## 1. Shortcuts (捷徑) Integration

Allow users to build powerful automation workflows using Zeal's search capabilities.

### Concept: "Search with Zeal" Action
Expose a "Search" action to the Shortcuts app.

**Example Use Cases:**
- **Selected Text Search**: A workflow that takes the currently selected text (from any app) and searches it in Zeal using a specific keyword (e.g., `dict selection`).
- **Daily Routine**: A "Morning Start" shortcut that opens Zeal to a specific dashboard page or documentation set.

**Hypothetical Code Definition:**
```swift
struct SearchIntent: AppIntent {
    static var title: LocalizedStringResource = "Search in Zeal"

    @Parameter(title: "Keyword")
    var keyword: String

    @Parameter(title: "Query")
    var query: String?

    func perform() async throws -> some IntentResult {
        // Implementation: Open Zeal and execute `keyword query`
        return .result()
    }
}
```

## 2. Siri Support

Enable voice control implementation via App Intents.

**Example Commands:**
- "Hey Siri, search documentation for `SwiftUI` in Zeal."
- "Hey Siri, open `GitHub` using Zeal."

All `AppIntent`s defined for Shortcuts are automatically available to Siri.

## 3. Spotlight Integration

Allow Zeal's keywords and results to appear directly in the system-wide Spotlight search (`Cmd + Space`), reducing the need to open Zeal separately for common tasks.

### Concept: AppEntity
Define Zeal Keywords as `AppEntity` so Spotlight can index them.

**Example Behavior:**
1. User invokes Spotlight (`Cmd + Space`).
2. User types "gh".
3. Spotlight shows a Zeal result: "Open GitHub (Zeal Keyword)".
4. Pressing Enter executes the action immediately.

**Hypothetical Code Definition:**
```swift
struct KeywordEntity: AppEntity {
    static var defaultQuery = KeywordQuery()
    var id: String
    var shortcut: String
    
    // Spotlight integration
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Zeal Keyword"
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(shortcut)")
    }
}
```

## Benefits of Implementation

1. **Accessibility**: Voice control makes the app more accessible.
2. **Productivity**: Automation via Shortcuts allows users to chain Zeal with other tools (e.g., Raycast, Calendar, Notes).
3. **Discoverability**: Spotlight integration brings Zeal's power to the system's native search interface.
