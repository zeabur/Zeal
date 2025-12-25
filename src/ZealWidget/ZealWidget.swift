//
//  ZealWidget.swift
//  ZealWidget
//
//  Created by Can on 2025/12/21.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Data

struct WidgetService: Codable, Identifiable {
    let id: String
    let name: String
    let status: String

    var statusColor: Color {
        switch status {
        case "RUNNING":
            return .green
        case "STARTING", "BUILDING", "PENDING":
            return .yellow
        case "CRASHED", "PULL_FAILED":
            return .red
        case "STOPPED", "SUSPENDED", "STOPPING":
            return .gray
        default:
            return .secondary
        }
    }
}

struct WidgetProject: Codable, Identifiable {
    let id: String
    let name: String
    let services: [WidgetService]
}

enum SharedDataManager {
    static let appGroupID = "group.com.zeabur.Zeal"
    static let projectsKey = "cachedProjects"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func loadProjects() -> [WidgetProject] {
        guard let defaults = sharedDefaults else {
            print("Widget: No shared defaults")
            return []
        }
        guard let data = defaults.data(forKey: projectsKey) else {
            print("Widget: No data for key")
            return []
        }
        do {
            let projects = try JSONDecoder().decode([WidgetProject].self, from: data)
            print("Widget: Loaded \(projects.count) projects")
            return projects
        } catch {
            print("Widget: Decode error - \(error)")
            return []
        }
    }
}

// MARK: - Timeline Entry

struct ProjectEntry: TimelineEntry {
    let date: Date
    let projects: [WidgetProject]
    let isPlaceholder: Bool

    static var placeholder: ProjectEntry {
        ProjectEntry(
            date: Date(),
            projects: [
                WidgetProject(id: "1", name: "my-app", services: [
                    WidgetService(id: "1", name: "web", status: "RUNNING"),
                    WidgetService(id: "2", name: "api", status: "RUNNING")
                ]),
                WidgetProject(id: "2", name: "api-server", services: [
                    WidgetService(id: "3", name: "server", status: "BUILDING")
                ]),
                WidgetProject(id: "3", name: "website", services: [
                    WidgetService(id: "4", name: "frontend", status: "RUNNING"),
                    WidgetService(id: "5", name: "backend", status: "CRASHED")
                ])
            ],
            isPlaceholder: true
        )
    }

    static var empty: ProjectEntry {
        ProjectEntry(date: Date(), projects: [], isPlaceholder: false)
    }
}

// MARK: - Timeline Provider

struct ProjectTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProjectEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ProjectEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            let projects = SharedDataManager.loadProjects()
            completion(ProjectEntry(date: Date(), projects: projects, isPlaceholder: false))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProjectEntry>) -> Void) {
        let projects = SharedDataManager.loadProjects()
        let entry = ProjectEntry(date: Date(), projects: projects, isPlaceholder: false)

        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Views

struct ZealWidgetEntryView: View {
    var entry: ProjectEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: ProjectEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let project = entry.projects.first {
                // Header
                HStack {
                    Image(systemName: "cube.fill")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text(project.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }

                // Services
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(project.services.prefix(4)) { service in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(service.statusColor)
                                .frame(width: 6, height: 6)
                            Text(service.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                    if project.services.count > 4 {
                        Text("+\(project.services.count - 4) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "cube.fill")
                        .foregroundColor(.purple)
                    Text("Zeabur")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                Spacer()
                Text("請開啟 Zeal 登入")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }
}

struct MediumWidgetView: View {
    let entry: ProjectEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cube.fill")
                    .foregroundColor(.purple)
                Text("Zeabur Projects")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(entry.projects.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
            }

            if entry.projects.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("請開啟 Zeal 登入")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 6) {
                    ForEach(entry.projects.prefix(4)) { project in
                        ProjectRow(project: project)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }
}

struct ProjectRow: View {
    let project: WidgetProject

    var overallStatusColor: Color {
        // Red if any service has error
        if project.services.contains(where: { $0.status == "CRASHED" || $0.status == "PULL_FAILED" }) {
            return .red
        }
        // Yellow if any service is in progress
        if project.services.contains(where: { ["STARTING", "BUILDING", "PENDING", "STOPPING"].contains($0.status) }) {
            return .yellow
        }
        // Green if all running
        if project.services.allSatisfy({ $0.status == "RUNNING" }) {
            return .green
        }
        return .gray
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(overallStatusColor)
                .frame(width: 8, height: 8)

            Text(project.name)
                .font(.caption)
                .lineLimit(1)

            Spacer()

            Text("\(project.services.count)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Widget Configuration

struct ZealWidget: Widget {
    let kind: String = "ZealWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProjectTimelineProvider()) { entry in
            ZealWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Zeabur Projects")
        .description("查看您的 Zeabur 專案狀態")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    ZealWidget()
} timeline: {
    ProjectEntry.placeholder
    ProjectEntry.empty
}
