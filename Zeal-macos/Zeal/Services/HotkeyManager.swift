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

        parts.append(currentKey.displayString)

        return parts.joined()
    }
}


