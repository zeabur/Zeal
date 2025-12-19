import AppKit
import HotKey
import Carbon

final class HotkeyManager: ObservableObject {
    static let shared = HotkeyManager()

    @Published var currentKey: Key = .space
    @Published var currentModifiers: NSEvent.ModifierFlags = .option

    var onActivate: (() -> Void)?

    private var hotKey: HotKey?

    private init() {
        loadSettings()
    }

    func registerHotkey() {
        hotKey = nil

        hotKey = HotKey(key: currentKey, modifiers: currentModifiers)
        hotKey?.keyDownHandler = { [weak self] in
            self?.onActivate?()
        }
    }

    func updateHotkey(key: Key, modifiers: NSEvent.ModifierFlags) {
        currentKey = key
        currentModifiers = modifiers
        saveSettings()
        registerHotkey()
    }

    private func loadSettings() {
        if let keyRawValue = UserDefaults.standard.object(forKey: "hotkeyKey") as? UInt32,
           let key = Key(carbonKeyCode: keyRawValue) {
            currentKey = key
        }

        if let modifiersRawValue = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt {
            currentModifiers = NSEvent.ModifierFlags(rawValue: modifiersRawValue)
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(currentKey.carbonKeyCode, forKey: "hotkeyKey")
        UserDefaults.standard.set(currentModifiers.rawValue, forKey: "hotkeyModifiers")
    }

    var hotkeyDescription: String {
        var parts: [String] = []

        if currentModifiers.contains(.control) { parts.append("⌃") }
        if currentModifiers.contains(.option) { parts.append("⌥") }
        if currentModifiers.contains(.shift) { parts.append("⇧") }
        if currentModifiers.contains(.command) { parts.append("⌘") }

        parts.append(keyDescription(currentKey))

        return parts.joined()
    }

    private func keyDescription(_ key: Key) -> String {
        switch key {
        case .space: return "Space"
        case .return: return "Return"
        case .tab: return "Tab"
        case .escape: return "Esc"
        case .delete: return "Delete"
        case .forwardDelete: return "Fwd Delete"
        case .home: return "Home"
        case .end: return "End"
        case .pageUp: return "Page Up"
        case .pageDown: return "Page Down"
        case .upArrow: return "↑"
        case .downArrow: return "↓"
        case .leftArrow: return "←"
        case .rightArrow: return "→"
        case .f1: return "F1"
        case .f2: return "F2"
        case .f3: return "F3"
        case .f4: return "F4"
        case .f5: return "F5"
        case .f6: return "F6"
        case .f7: return "F7"
        case .f8: return "F8"
        case .f9: return "F9"
        case .f10: return "F10"
        case .f11: return "F11"
        case .f12: return "F12"
        default:
            if let char = key.description.first?.uppercased() {
                return char
            }
            return key.description.uppercased()
        }
    }
}
