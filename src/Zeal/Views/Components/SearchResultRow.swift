import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            // App icon or keyword indicator
            // App icon, keyword indicator, or status dot
            if let icon = result.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
            } else if let status = result.status {
                 // Status Dot
                Circle()
                    .fill(statusColor(for: status))
                    .frame(width: 12, height: 12)
                    .padding(6) // Align with 24x24 icon space
            } else {
                Image(systemName: "link")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
            }

            Text(result.title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            // Temporary Debug
            if case .zeabur = result {
               Text(result.status != nil ? "[Status: OK]" : "[Status: NIL]")
                   .font(.caption)
                   .foregroundColor(.red)
            }

            if let subtitle = result.subtitle {
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if result.isParameterized {
                Text("tab ⇥")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(isSelected ? Color.primary.opacity(0.06) : Color.clear)
        .contentShape(Rectangle())
    }
    
    private func statusColor(for status: SearchResult.ServiceStatus) -> Color {
        switch status {
        case .deployed: return .green
        case .failed: return .red
        case .deploying: return .yellow
        case .none: return .gray
        }
    }
}
