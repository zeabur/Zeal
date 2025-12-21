import SwiftUI

enum KeywordEditorMode {
    case add
    case edit(Keyword)

    var isEditing: Bool {
        if case .edit = self { return true }
        return false
    }

    var keyword: Keyword? {
        if case .edit(let keyword) = self { return keyword }
        return nil
    }
}

struct KeywordEditorView: View {
    let mode: KeywordEditorMode
    let onSave: (Keyword) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = KeywordStore.shared

    @State private var shortcut = ""
    @State private var name = ""
    @State private var url = ""
    @State private var isEnabled = true
    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !mode.isEditing {
                Text("New Keyword")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }

            form

            if !mode.isEditing {
                footer
            }
        }
        .frame(width: mode.isEditing ? nil : 380)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            if let keyword = mode.keyword {
                shortcut = keyword.shortcut
                name = keyword.name
                url = keyword.url
                isEnabled = keyword.isEnabled
            }
        }
        .alert("Error", isPresented: .init(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error ?? "")
        }
    }

    // MARK: - Form

    private var form: some View {
        VStack(alignment: .leading, spacing: 20) {
            FormField("Short Name", placeholder: "GitHub", text: $shortcut)
            FormField("Description", placeholder: "Open GitHub homepage", text: $name)
            FormField("URL", placeholder: "https://github.com", text: $url)

            if url.contains("{param}") {
                Text("Parameter detected — use tab to select, then enter parameter")
                    .font(.system(size: 11))
                    .foregroundColor(.orange.opacity(0.8))
            }

            if mode.isEditing {
                Button(action: save) {
                    Text("Save")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isValid ? Color.accentColor : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .disabled(!isValid)
                .padding(.top, 4)
            }
        }
        .padding(20)
    }

    private var footer: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .keyboardShortcut(.escape)

            Spacer()

            Button(action: save) {
                Text("Add")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isValid ? .white : .secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(isValid ? Color.accentColor : Color.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return)
            .disabled(!isValid)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Logic

    private var isValid: Bool {
        !shortcut.trimmingCharacters(in: .whitespaces).isEmpty &&
        !url.trimmingCharacters(in: .whitespaces).isEmpty &&
        (url.hasPrefix("http://") || url.hasPrefix("https://"))
    }

    private func save() {
        let keyword = Keyword(
            id: mode.keyword?.id ?? UUID(),
            shortcut: shortcut.trimmingCharacters(in: .whitespaces),
            name: name.trimmingCharacters(in: .whitespaces),
            url: url.trimmingCharacters(in: .whitespaces),
            isEnabled: isEnabled
        )

        onSave(keyword)

        if !mode.isEditing {
            dismiss()
        }
    }
}

// MARK: - Components

private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    init(_ label: String, placeholder: String, text: Binding<String>) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
