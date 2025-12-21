import WidgetKit
import AppIntents

struct SelectProjectIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Project"
    static var description: IntentDescription = "Choose a Zeabur project to display status for."

    @Parameter(title: "Project")
    var project: ProjectEntity?
}

struct ProjectEntity: AppEntity {
    let id: String
    let name: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Project"
    static var defaultQuery = ProjectQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ProjectQuery: EntityQuery {
    func entities(for identifiers: [ProjectEntity.ID]) async throws -> [ProjectEntity] {
        let allProjects = await fetchProjects()
        return allProjects.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [ProjectEntity] {
        return await fetchProjects()
    }
    
    func defaultResult() async -> ProjectEntity? {
        return try? await suggestedEntities().first
    }
    
    private func fetchProjects() async -> [ProjectEntity] {
        // Authenticate check
        guard ZeaburService.shared.isAuthenticated else { return [] }
        
        do {
            let projects = try await ZeaburService.shared.fetchProjects(forceRefresh: false)
            return projects.map { ProjectEntity(id: $0._id, name: $0.name) }
        } catch {
            print("Intent fetch error: \(error)")
            return []
        }
    }
}
