import Foundation
import WidgetKit

final class ZeaburService {
    static let shared = ZeaburService()

    private let apiEndpoint = URL(string: "https://api.zeabur.com/graphql")!
    private let keychainKey = "com.zeabur.zeal.apikey"

    // App Group for Widget sharing
    private let appGroupID = "group.com.zeabur.Zeal"
    private let widgetProjectsKey = "cachedProjects"

    // Simple memory cache
    private var cachedProjects: [ZeaburProject]?
    private var cachedUser: ZeaburUser?
    private var lastFetchTime: Date?
    private let cacheTTL: TimeInterval = 300 // 5 minutes
    
    // Published property to allow views to react to auth state changes
    // Note: Since this is a singleton, we might want to use ObservableObject or similar pattern
    // For now, we'll keep it simple and just provide accessors.
    
    var user: ZeaburUser? {
        return cachedUser
    }
    
    var apiKey: String? {
        get { KeychainService.shared.load(key: keychainKey) }
        set {
            if let value = newValue {
                try? KeychainService.shared.save(key: keychainKey, value: value)
            } else {
                try? KeychainService.shared.delete(key: keychainKey)
                self.cachedUser = nil
                self.cachedProjects = nil
                self.clearWidgetData()
            }
        }
    }
    
    var isAuthenticated: Bool {
        return apiKey != nil
    }

    // MARK: - Widget Data Sharing

    struct WidgetService: Codable {
        let id: String
        let name: String
        let status: String
    }

    struct WidgetProject: Codable {
        let id: String
        let name: String
        let services: [WidgetService]
    }

    private func saveProjectsForWidget(_ projects: [ZeaburProject]) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("Widget: Failed to get UserDefaults")
            return
        }

        let widgetProjects = projects.map { project in
            WidgetProject(
                id: project._id,
                name: project.name,
                services: project.services.map { service in
                    WidgetService(
                        id: service._id,
                        name: service.name,
                        status: service.status?.rawValue ?? "UNKNOWN"
                    )
                }
            )
        }

        do {
            let data = try JSONEncoder().encode(widgetProjects)
            defaults.set(data, forKey: widgetProjectsKey)
            print("Widget: Saved \(widgetProjects.count) projects, \(data.count) bytes")
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Widget: Encode error - \(error)")
        }
    }

    private func clearWidgetData() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        defaults.removeObject(forKey: widgetProjectsKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    enum APIError: Error {
        case invalidURL
        case noData
        case decodingError
        case serverError(String)
        case notAuthenticated
    }
    
    func validateAPIKey(key: String) async throws -> ZeaburUser {
        let query = """
        query {
          me {
            _id
            username
            name
          }
        }
        """
        
        let payload: [String: Any] = ["query": query]
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        
        var request = URLRequest(url: apiEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError("Invalid response code")
        }
        
        do {
            let result = try JSONDecoder().decode(MeResponse.self, from: data)
            self.cachedUser = result.data.me
            return result.data.me
        } catch {
             // If decoding fails, check if it's a GraphQL error
             if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let errors = json["errors"] as? [[String: Any]],
                let message = errors.first?["message"] as? String {
                 throw APIError.serverError(message)
             }
            throw APIError.decodingError
        }
    }
    
    func fetchProjects(forceRefresh: Bool = false) async throws -> [ZeaburProject] {
        guard let apiKey = apiKey else { throw APIError.notAuthenticated }
        
        // Return cache if valid
        if !forceRefresh, let projects = cachedProjects, let lastFetch = lastFetchTime, Date().timeIntervalSince(lastFetch) < cacheTTL {
            print("Returning cached projects (\(projects.count))")
            return projects
        }
        
        let query = """
        query {
          projects {
            edges {
              node {
                _id
                name
                services {
                  _id
                  name
                  status
                }
              }
            }
          }
        }
        """
        
        let payload: [String: Any] = ["query": query]
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        
        var request = URLRequest(url: apiEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid response type")
        }
        
        // Debug
        print("API Status Code: \(httpResponse.statusCode)")
        // if let str = String(data: data, encoding: .utf8) { print("Projects Response: \(str)") }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError("Invalid response code: \(httpResponse.statusCode)")
        }
        
        do {
            let result = try JSONDecoder().decode(ProjectsResponse.self, from: data)
            let projects = result.data.projects.edges.map { $0.node }
            print("Decoded \(projects.count) projects")
            
            // Update cache
            self.cachedProjects = projects
            self.lastFetchTime = Date()

            // Save for Widget
            self.saveProjectsForWidget(projects)

            return projects
        } catch {
             print("Decoding error: \(error)")
             if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let errors = json["errors"] as? [[String: Any]],
                let message = errors.first?["message"] as? String {
                 throw APIError.serverError(message)
             }
            throw APIError.decodingError
        }
    }
}
