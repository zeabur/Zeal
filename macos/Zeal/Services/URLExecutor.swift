import AppKit

enum URLExecutor {
    static func open(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    static func execute(keyword: Keyword, param: String?) {
        guard let url = keyword.buildURL(with: param) else {
            print("Failed to build URL for keyword: \(keyword.name)")
            return
        }
        open(url)
    }
}
