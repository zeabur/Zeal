import SwiftUI
import ServiceManagement
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var store = KeywordStore.shared
    @StateObject private var hotkeyManager = HotkeyManager.shared
    @State private var isAdding = false
    @State private var editingKeyword: Keyword?
    @State private var launchAtLogin = false
    @State private var apiKey = ""
    @State private var zeaburUser: ZeaburUser?
    @State private var isVerifying = false
    @State private var authError: String?

    // Load initial state
    private func loadState() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
        if let key = ZeaburService.shared.apiKey {
            apiKey = key
            // Optimistically fetch user info if key exists
            verifyKey(key, silent: true)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                generalSection
                Divider().opacity(0.5)
                keywordsSection
                Divider().opacity(0.5)
                aboutSection
            }
            .padding(24)
        }
        .frame(width: 480, height: 600)
        .onAppear { loadState() }
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



    // MARK: - General Section
    
    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("General")
            
            // Authentication
            VStack(alignment: .leading, spacing: 8) {
                Text("Zeabur Account")
                    .font(.system(size: 13, weight: .medium))
                
                if let user = zeaburUser {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.system(size: 13, weight: .medium))
                            Text("@\(user.username)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Sign Out") {
                            ZeaburService.shared.apiKey = nil
                            apiKey = ""
                            zeaburUser = nil
                        }
                        .controlSize(.small)
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                } else {
                    HStack {
                        SecureField("API Key", text: $apiKey)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: { verifyKey(apiKey) }) {
                            if isVerifying {
                                ProgressView().controlSize(.small)
                            } else {
                                Text("Verify")
                            }
                        }
                        .disabled(apiKey.isEmpty || isVerifying)
                    }
                    
                    if let error = authError {
                        Text(error)
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                    
                    Text("Enter your Zeabur API Key to access your projects.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider().opacity(0.5).padding(.vertical, 8)
            
            // System Settings
            VStack(spacing: 12) {
                HStack {
                    Text("Global Hotkey")
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

    private func verifyKey(_ key: String, silent: Bool = false) {
        guard !key.isEmpty else { return }
        isVerifying = true
        authError = nil
        
        Task {
            do {
                let user = try await ZeaburService.shared.validateAPIKey(key: key)
                await MainActor.run {
                    self.zeaburUser = user
                    // Only save if explicitly verifying (not checking loaded key)
                    if !silent {
                        ZeaburService.shared.apiKey = key
                    }
                    self.isVerifying = false
                }
            } catch {
                await MainActor.run {
                    if !silent {
                        self.authError = "Invalid API Key"
                    }
                    if !silent {
                        // Clear invalid key if we were trying to save it
                         ZeaburService.shared.apiKey = nil
                    }
                    self.isVerifying = false
                }
            }
        }
    }

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


