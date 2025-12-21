import AppKit
import Combine

struct AppResult: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let path: String
    let bundleIdentifier: String?

    var icon: NSImage? {
        NSWorkspace.shared.icon(forFile: path)
    }

    func launch() {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
}

final class AppSearchService: ObservableObject {
    static let shared = AppSearchService()

    @Published private(set) var results: [AppResult] = []

    private var allApps: [AppResult] = []
    private var isLoaded = false

    private init() {
        loadApps()
    }

    private func loadApps() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var apps: [AppResult] = []

            let directories = [
                "/Applications",
                "/System/Applications",
                "/System/Applications/Utilities",
                NSHomeDirectory() + "/Applications"
            ]

            let fileManager = FileManager.default

            for directory in directories {
                guard let contents = try? fileManager.contentsOfDirectory(atPath: directory) else {
                    continue
                }

                for item in contents where item.hasSuffix(".app") {
                    let path = (directory as NSString).appendingPathComponent(item)
                    let name = (item as NSString).deletingPathExtension

                    // Get bundle identifier
                    let bundleURL = URL(fileURLWithPath: path)
                    let bundle = Bundle(url: bundleURL)
                    let bundleId = bundle?.bundleIdentifier

                    let app = AppResult(
                        id: path,
                        name: name,
                        path: path,
                        bundleIdentifier: bundleId
                    )
                    apps.append(app)
                }
            }

            // Sort alphabetically
            apps.sort { $0.name.lowercased() < $1.name.lowercased() }

            DispatchQueue.main.async {
                self?.allApps = apps
                self?.isLoaded = true
            }
        }
    }

    func search(_ text: String) {
        guard !text.isEmpty else {
            results = []
            return
        }

        let searchLower = text.lowercased()

        // Filter apps that match the search text
        var matched = allApps.filter { app in
            app.name.lowercased().contains(searchLower)
        }

        // Sort by relevance: exact match > prefix > contains
        matched.sort { a, b in
            let aName = a.name.lowercased()
            let bName = b.name.lowercased()

            let aExact = aName == searchLower
            let bExact = bName == searchLower
            if aExact != bExact { return aExact }

            let aPrefix = aName.hasPrefix(searchLower)
            let bPrefix = bName.hasPrefix(searchLower)
            if aPrefix != bPrefix { return aPrefix }

            return aName < bName
        }

        // Limit results
        results = Array(matched.prefix(8))
    }

    func stop() {
        results = []
    }
}
