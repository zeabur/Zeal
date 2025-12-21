import Foundation

struct Keyword: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var shortcut: String
    var name: String
    var url: String
    var isEnabled: Bool

    var isParameterized: Bool {
        url.contains("{param}")
    }

    init(id: UUID = UUID(), shortcut: String, name: String, url: String, isEnabled: Bool = true) {
        self.id = id
        self.shortcut = shortcut
        self.name = name
        self.url = url
        self.isEnabled = isEnabled
    }

    func buildURL(with param: String?) -> URL? {
        guard isParameterized, let param else {
            return URL(string: url)
        }

        let encoded = url.contains("?") || url.contains("&")
            ? param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? param
            : param.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? param

        return URL(string: url.replacingOccurrences(of: "{param}", with: encoded))
    }
}
