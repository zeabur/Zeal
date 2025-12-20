import AppKit

enum SearchResult: Identifiable, Equatable, Hashable {
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    case keyword(Keyword)
    case app(AppResult)
    case zeabur(id: String, title: String, subtitle: String, action: () -> Void)

    var id: String {
        switch self {
        case .keyword(let keyword):
            return "keyword-\(keyword.id.uuidString)"
        case .app(let app):
            return "app-\(app.id)"
        case .zeabur(let id, _, _, _):
            return id
        }
    }

    var title: String {
        switch self {
        case .keyword(let keyword):
            return keyword.shortcut
        case .app(let app):
            return app.name
        case .zeabur(_, let title, _, _):
            return title
        }
    }

    var subtitle: String? {
        switch self {
        case .keyword(let keyword):
            return keyword.name.isEmpty ? nil : keyword.name
        case .app:
            return "Application"
        case .zeabur(_, _, let subtitle, _):
            return subtitle
        }
    }

    var isParameterized: Bool {
        switch self {
        case .keyword(let keyword):
            return keyword.isParameterized
        case .app, .zeabur:
            return false
        }
    }

    var icon: NSImage? {
        switch self {
        case .keyword:
            return nil
        case .app(let app):
            return app.icon
        case .zeabur:
            // TODO: Use a proper icon (e.g. from Asset catalog)
            // For now, return nil which renders a fallback or we can use SF Symbol in the view
            return nil
        }
    }

    func execute(param: String?) {
        switch self {
        case .keyword(let keyword):
            URLExecutor.execute(keyword: keyword, param: param)
        case .app(let app):
            app.launch()
        case .zeabur(_, _, _, let action):
            action()
        }
    }
}
