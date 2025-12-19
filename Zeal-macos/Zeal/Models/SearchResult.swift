import AppKit

enum SearchResult: Identifiable, Equatable, Hashable {
    case keyword(Keyword)
    case app(AppResult)

    var id: String {
        switch self {
        case .keyword(let keyword):
            return "keyword-\(keyword.id.uuidString)"
        case .app(let app):
            return "app-\(app.id)"
        }
    }

    var title: String {
        switch self {
        case .keyword(let keyword):
            return keyword.shortcut
        case .app(let app):
            return app.name
        }
    }

    var subtitle: String? {
        switch self {
        case .keyword(let keyword):
            return keyword.name.isEmpty ? nil : keyword.name
        case .app:
            return "Application"
        }
    }

    var isParameterized: Bool {
        switch self {
        case .keyword(let keyword):
            return keyword.isParameterized
        case .app:
            return false
        }
    }

    var icon: NSImage? {
        switch self {
        case .keyword:
            return nil
        case .app(let app):
            return app.icon
        }
    }

    func execute(param: String?) {
        switch self {
        case .keyword(let keyword):
            URLExecutor.execute(keyword: keyword, param: param)
        case .app(let app):
            app.launch()
        }
    }
}
