import SwiftUI
import ServiceManagement
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var store = KeywordStore.shared
    @StateObject private var hotkeyManager = HotkeyManager.shared
    @State private var isAdding = false
    @State private var editingKeyword: Keyword?
    @State private var launchAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                keywordsSection
                Divider().opacity(0.5)
                settingsSection
                Divider().opacity(0.5)
                aboutSection
            }
            .padding(24)
        }
        .frame(width: 480, height: 520)
        .onAppear { launchAtLogin = SMAppService.mainApp.status == .enabled }
        .sheet(isPresented: $isAdding) {
            KeywordEditorView(mode: .add) { keyword in
                store.add(keyword)
            }
        }
        .sheet(item: $editingKeyword) { keyword in
            KeywordEditorView(mode: .edit(keyword)) { updated in
                store.update(updated)
            }
        }
    }

    // MARK: - Keywords Section

    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader("Keywords")
                Spacer()
                Button(action: { isAdding = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }

            if store.keywords.isEmpty {
                Text("No keywords yet")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(store.keywords) { keyword in
                        KeywordRow(
                            keyword: keyword,
                            onToggle: { store.toggleEnabled(keyword) },
                            onEdit: { editingKeyword = keyword },
                            onDelete: { store.delete(keyword) }
                        )

                        if keyword.id != store.keywords.last?.id {
                            Divider().opacity(0.3).padding(.leading, 32)
                        }
                    }
                }
                .background(Color.primary.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("Settings")

            VStack(spacing: 12) {
                HStack {
                    Text("Hotkey")
                        .font(.system(size: 13))
                    Spacer()
                    Text(hotkeyManager.hotkeyDescription)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .modifier(PillStyle())
                }

                HStack {
                    Text("Launch at login")
                        .font(.system(size: 13))
                    Spacer()
                    Toggle("", isOn: $launchAtLogin)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                        .labelsHidden()
                        .onChange(of: launchAtLogin) { _, on in
                            try? on ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
                        }
                }

                HStack(spacing: 10) {
                    ActionButton("Export") { exportKeywords() }
                    ActionButton("Import") { importKeywords() }
                    Spacer()
                    Button("Open Folder") { openConfigFolder() }
                        .buttonStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("About")

            HStack {
                Text("Version")
                    .font(.system(size: 13))
                Spacer()
                Text("\(AppInfo.version) (\(AppInfo.gitSHA))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func openConfigFolder() {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Zeal")
        NSWorkspace.shared.open(url)
    }

    private func exportKeywords() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "zeal-keywords.json"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(store.keywords).write(to: url)
        } catch {
            showAlert("Export Failed", error.localizedDescription)
        }
    }

    private func importKeywords() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let data = try Data(contentsOf: url)
            let imported = try JSONDecoder().decode([Keyword].self, from: data)

            var added = 0, skipped = 0
            for keyword in imported {
                if store.keywords.contains(where: { $0.name == keyword.name }) {
                    skipped += 1
                } else {
                    store.add(keyword)
                    added += 1
                }
            }

            showAlert("Import Complete", "Added \(added), skipped \(skipped) duplicates.")
        } catch {
            showAlert("Import Failed", error.localizedDescription)
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
}

// MARK: - Components

private struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

private struct KeywordRow: View {
    let keyword: Keyword
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: keyword.isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(keyword.isEnabled ? .accentColor : .secondary.opacity(0.4))
            }
            .buttonStyle(.plain)

            Text(keyword.shortcut)
                .font(.system(size: 13))
                .foregroundColor(keyword.isEnabled ? .primary : .secondary)
                .lineLimit(1)

            if keyword.isParameterized {
                Text("param")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.orange.opacity(0.8))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }

            Spacer()

            if isHovering {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

private struct ActionButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.primary)
            .modifier(PillStyle())
    }
}

private struct PillStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - App Info

private enum AppInfo {
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
    }

    static var gitSHA: String {
        let sha = Bundle.main.object(forInfoDictionaryKey: "GitCommitSHA") as? String ?? ""
        if sha.isEmpty || sha == "$(GIT_COMMIT_SHA)" {
            return "dev"
        }
        return String(sha.prefix(7))
    }
}
