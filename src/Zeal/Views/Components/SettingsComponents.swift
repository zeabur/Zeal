import SwiftUI

// MARK: - Components

struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

struct KeywordRow: View {
    let keyword: Keyword
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: keyword.isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(keyword.isEnabled ? .accentColor : .secondary.opacity(0.4))
            }
            .buttonStyle(.plain)

            Text(keyword.shortcut)
                .font(.system(size: 13))
                .foregroundColor(keyword.isEnabled ? .primary : .secondary)
                .lineLimit(1)

            if keyword.isParameterized {
                Text("param")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.orange.opacity(0.8))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }

            Spacer()

            if isHovering {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                    .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

struct ActionButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.primary)
            .modifier(PillStyle())
    }
}

struct PillStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
