import Foundation
import AppKit

struct ZeaburSearchProvider {
    static func search(query: String) async -> [SearchResult] {
        guard ZeaburService.shared.isAuthenticated else {
             print("ZeaburSearchProvider: Not authenticated")
             return [] 
        }
        
        print("ZeaburSearchProvider: Searching for '\(query)'")
        
        // Define a trigger prefix, e.g. "z " or "zeabur "
        // Or just search if query matches known project names
        // utilizing a simple "contains" strategy for now for broader discovery
        
        do {
            // TODO: Cache this result or fetch only on specific triggers to avoid API spam
            // For MVP, we fetch on every keystroke if it looks like a Zeabur query,
            // but to be safe and fast, let's fetch once on app launch or assume
            // we have a local cache.
            // For now, let's assume we want to search projects.
            
            let projects = try await ZeaburService.shared.fetchProjects()
            
            let lowerQuery = query.lowercased()
            
            return projects.filter {
                $0.name.lowercased().contains(lowerQuery) ||
                $0.services.contains { $0.name.lowercased().contains(lowerQuery) }
            }.map { project in
                SearchResult.zeabur(
                    id: "zeabur-project-\(project.id)",
                    title: project.name,
                    subtitle: "Zeabur Project • \(project.services.count) Services",
                    action: {
                        if let url = URL(string: "https://dash.zeabur.com/projects/\(project.id)") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                )
            }
        } catch {
            print("Zeabur search error: \(error)")
            return []
        }
    }
}
