import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            // App icon or keyword indicator
            if let icon = result.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "link")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
            }

            Text(result.title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)

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
}
