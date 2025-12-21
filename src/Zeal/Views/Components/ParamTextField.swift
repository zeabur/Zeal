import SwiftUI
import AppKit

// MARK: - ParamTextField (NSTextField wrapper for backspace detection)

struct ParamTextField: NSViewRepresentable {
    @Binding var text: String
    var onBackspaceWhenEmpty: () -> Void
    var onEscape: () -> Void
    var onSubmit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = BackspaceDetectingTextField()
        textField.delegate = context.coordinator
        textField.onBackspaceWhenEmpty = onBackspaceWhenEmpty
        textField.onEscape = onEscape
        textField.font = NSFont.systemFont(ofSize: 24, weight: .regular)
        textField.isBordered = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.placeholderString = "Enter parameter..."

        // Focus the text field after a short delay
        DispatchQueue.main.async {
            textField.window?.makeFirstResponder(textField)
        }

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        if let tf = nsView as? BackspaceDetectingTextField {
            tf.onBackspaceWhenEmpty = onBackspaceWhenEmpty
            tf.onEscape = onEscape
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: ParamTextField

        init(_ parent: ParamTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                parent.onSubmit()
                return true
            }
            if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
                if parent.text.isEmpty {
                    parent.onBackspaceWhenEmpty()
                    return true
                }
            }
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.onEscape()
                return true
            }
            return false
        }
    }
}

class BackspaceDetectingTextField: NSTextField {
    var onBackspaceWhenEmpty: (() -> Void)?
    var onEscape: (() -> Void)?
}
