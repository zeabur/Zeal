import SwiftUI
import WidgetKit

struct ZealWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if family == .systemSmall {
                ZealWidgetSmallView(entry: entry)
            } else {
                ZealWidgetMediumView(entry: entry)
            }
        }
        // Background color is handled in ZealWidget.swift configuration
    }
}

struct ZealWidgetSmallView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                    .font(.caption)
                Text("Zeabur")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()

            if !entry.isAuthenticated {
                Text("Not logged in")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            } else if let error = entry.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
            } else if entry.projects.isEmpty {
                Text("No Projects")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                // Summary for Small Widget
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.projects.count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Projects")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ZealWidgetMediumView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("Zeabur Projects")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }

            if !entry.isAuthenticated {
                Text("Please login in Zeal app.")
                    .font(.caption)
                    .foregroundColor(.yellow)
            } else if let error = entry.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            } else if entry.projects.isEmpty {
                Text("No projects found.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 8) {
                    ForEach(entry.projects.prefix(3), id: \.id) { project in
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text(project.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                            Text("\(project.services.count)")
                                .font(.system(size: 10))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(4)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}
