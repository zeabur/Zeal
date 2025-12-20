import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), projects: [
            ZeaburProject(_id: "1", name: "My Project", services: []),
            ZeaburProject(_id: "2", name: "Demo App", services: [])
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), projects: [
            ZeaburProject(_id: "1", name: "My Project", services: [ZeaburServiceItem(_id: "s1", name: "web")]),
            ZeaburProject(_id: "2", name: "Demo App", services: [])
        ])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            var projects: [ZeaburProject] = []
            
            // Attempt to fetch real data
            if ZeaburService.shared.isAuthenticated {
                do {
                    // Force refresh to get latest status
                    projects = try await ZeaburService.shared.fetchProjects(forceRefresh: true)
                    // limit to top 3
                    projects = Array(projects.prefix(3))
                } catch {
                    print("Widget fetch error: \(error)")
                }
            } else {
                print("Widget: Not authenticated")
            }
            
            let entry = SimpleEntry(date: Date(), projects: projects)
            
            // Refresh every 15 minutes or when app data changes
            // Note: Background fetches are limited by iOS/macOS budgeting
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let projects: [ZeaburProject]
}
