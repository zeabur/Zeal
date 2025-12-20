import SwiftUI
import WidgetKit

struct ZealWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("Zeabur")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if entry.projects.isEmpty {
                if ZeaburService.shared.isAuthenticated {
                    Text("No projects found.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text("Please login in Zeal app.")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            } else {
                ForEach(entry.projects, id: \.id) { project in
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading) {
                            Text(project.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("\(project.services.count)")
                            .font(.system(size: 10))
                            .padding(4)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            Spacer()
        }
        .padding()
        // Dark background matching Zeabur theme

    }
}
