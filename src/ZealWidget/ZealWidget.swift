//
//  ZealWidget.swift
//  ZealWidget
//
//  Created by Can on 2025/12/21.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Data

struct WidgetProject: Codable, Identifiable {
    let id: String
    let name: String
    let serviceCount: Int
}

enum SharedDataManager {
    static let appGroupID = "group.com.zeabur.Zeal"
    static let projectsKey = "cachedProjects"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func loadProjects() -> [WidgetProject] {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: projectsKey),
              let projects = try? JSONDecoder().decode([WidgetProject].self, from: data) else {
            return []
        }
        return projects
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
                WidgetProject(id: "1", name: "my-app", serviceCount: 2),
                WidgetProject(id: "2", name: "api-server", serviceCount: 1),
                WidgetProject(id: "3", name: "website", serviceCount: 3)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cube.fill")
                    .foregroundColor(.purple)
                Text("Zeabur")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if entry.projects.isEmpty {
                Spacer()
                Text("請開啟 Zeal 登入")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                Spacer()
                Text("\(entry.projects.count)")
                    .font(.system(size: 36, weight: .bold))
                Text("專案")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)

            Text(project.name)
                .font(.caption)
                .lineLimit(1)

            Spacer()
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
