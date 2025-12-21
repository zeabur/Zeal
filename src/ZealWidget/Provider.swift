import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            projects: [
                ZeaburProject(_id: "1", name: "My Project", services: []),
                ZeaburProject(_id: "2", name: "Demo App", services: [])
            ],
            isAuthenticated: true
        )
    }

    func snapshot(for configuration: SelectProjectIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            projects: [
                ZeaburProject(_id: "1", name: "My Project", services: [ZeaburServiceItem(_id: "s1", name: "web")]),
                ZeaburProject(_id: "2", name: "Demo App", services: [])
            ],
            isAuthenticated: true
        )
    }

    func timeline(for configuration: SelectProjectIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var projects: [ZeaburProject] = []
        var errorMessage: String?
        let isAuthenticated = ZeaburService.shared.isAuthenticated

        // Attempt to fetch real data
        if isAuthenticated {
            do {
                // Force refresh to get latest status
                let allProjects = try await ZeaburService.shared.fetchProjects(forceRefresh: true)

                if let selectedProject = configuration.project {
                    // Filter for the selected project
                    projects = allProjects.filter { $0._id == selectedProject.id }
                } else {
                    // Default to top 3 if nothing selected
                    projects = Array(allProjects.prefix(3))
                }
            } catch {
                print("Widget fetch error: \(error)")
                errorMessage = "Failed to load projects"
            }
        } else {
            print("Widget: Not authenticated")
        }

        let entry = SimpleEntry(
            date: Date(),
            projects: projects,
            isAuthenticated: isAuthenticated,
            errorMessage: errorMessage
        )

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let projects: [ZeaburProject]
    let isAuthenticated: Bool
    let errorMessage: String?

    init(date: Date, projects: [ZeaburProject], isAuthenticated: Bool = false, errorMessage: String? = nil) {
        self.date = date
        self.projects = projects
        self.isAuthenticated = isAuthenticated
        self.errorMessage = errorMessage
    }
}
