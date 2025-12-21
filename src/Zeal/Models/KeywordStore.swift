import Foundation
import Combine

final class KeywordStore: ObservableObject {
    static let shared = KeywordStore()

    @Published private(set) var keywords: [Keyword] = []

    private let fileURL: URL
    private let backupURL: URL
    private var fileMonitor: DispatchSourceFileSystemObject?

    private init() {
        let baseDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Zeal", isDirectory: true)

        try? FileManager.default.createDirectory(at: baseDir, withIntermediateDirectories: true)

        fileURL = baseDir.appendingPathComponent("keywords.json")
        backupURL = baseDir.appendingPathComponent("keywords.backup.json")

        load()
        startFileMonitor()
    }

    // MARK: - Persistence

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            loadDefaults()
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            keywords = try JSONDecoder().decode([Keyword].self, from: data)
        } catch {
            loadBackup()
        }
    }

    private func loadDefaults() {
        guard let url = Bundle.main.url(forResource: "default-keywords", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let defaults = try? JSONDecoder().decode([Keyword].self, from: data) else {
            keywords = []
            save()
            return
        }
        keywords = defaults
        save()
    }

    private func save() {
        do {
            backup()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(keywords).write(to: fileURL, options: .atomic)
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func backup() {
        try? FileManager.default.removeItem(at: backupURL)
        try? FileManager.default.copyItem(at: fileURL, to: backupURL)
    }

    private func loadBackup() {
        guard FileManager.default.fileExists(atPath: backupURL.path),
              let data = try? Data(contentsOf: backupURL),
              let restored = try? JSONDecoder().decode([Keyword].self, from: data) else {
            keywords = []
            save()
            return
        }
        keywords = restored
    }

    private func startFileMonitor() {
        let fd = open(fileURL.path, O_EVTONLY)
        guard fd >= 0 else { return }

        fileMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: .write,
            queue: .main
        )
        fileMonitor?.setEventHandler { [weak self] in self?.load() }
        fileMonitor?.setCancelHandler { close(fd) }
        fileMonitor?.resume()
    }

    // MARK: - CRUD

    func add(_ keyword: Keyword) {
        keywords.append(keyword)
        save()
    }

    func update(_ keyword: Keyword) {
        guard let index = keywords.firstIndex(where: { $0.id == keyword.id }) else { return }
        keywords[index] = keyword
        save()
    }

    func delete(_ keyword: Keyword) {
        keywords.removeAll { $0.id == keyword.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        keywords.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Query

    func search(_ query: String) -> [Keyword] {
        let enabled = keywords.filter { $0.isEnabled }
        guard !query.isEmpty else { return enabled }

        let q = query.lowercased()

        // Filter by shortcut or name
        let matched = enabled.filter {
            $0.shortcut.lowercased().contains(q) ||
            $0.name.lowercased().contains(q)
        }

        // Sort: exact shortcut match > shortcut prefix > shortcut contains > name match
        return matched.sorted { a, b in
            let aShortcut = a.shortcut.lowercased()
            let bShortcut = b.shortcut.lowercased()

            let aExact = aShortcut == q
            let bExact = bShortcut == q
            if aExact != bExact { return aExact }

            let aPrefix = aShortcut.hasPrefix(q)
            let bPrefix = bShortcut.hasPrefix(q)
            if aPrefix != bPrefix { return aPrefix }

            let aContains = aShortcut.contains(q)
            let bContains = bShortcut.contains(q)
            if aContains != bContains { return aContains }

            return a.shortcut < b.shortcut
        }
    }

    func toggleEnabled(_ keyword: Keyword) {
        guard let index = keywords.firstIndex(where: { $0.id == keyword.id }) else { return }
        keywords[index].isEnabled.toggle()
        save()
    }
}
