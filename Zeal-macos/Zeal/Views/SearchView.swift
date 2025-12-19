import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @FocusState private var isSearchFieldFocused: Bool
    @FocusState private var isParamFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchField

            if !viewModel.results.isEmpty {
                Divider().opacity(0.5)
                resultsList
            }
        }
        .frame(width: 580, height: dynamicHeight)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .onAppear {
            isSearchFieldFocused = true
        }
        .onChange(of: viewModel.lockedResult) { _, newValue in
            if newValue != nil {
                isParamFieldFocused = true
            } else {
                isSearchFieldFocused = true
            }
        }
    }

    private var dynamicHeight: CGFloat {
        if viewModel.lockedResult != nil {
            return 68
        }
        return viewModel.results.isEmpty ? 68 : 420
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            if let title = viewModel.lockedTitle {
                // Locked state: show keyword shortcut + param input
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                ParamTextField(
                    text: $viewModel.paramText,
                    onBackspaceWhenEmpty: {
                        viewModel.unlock()
                    },
                    onEscape: {
                        viewModel.dismiss()
                    },
                    onSubmit: {
                        viewModel.execute()
                    }
                )
                .focused($isParamFieldFocused)
                .onAppear { isParamFieldFocused = true }
            } else {
                // Search state: show search input with autocomplete hint
                ZStack(alignment: .leading) {
                    // Autocomplete hint (grey text)
                    if let hint = viewModel.autocompleteHint {
                        Text(hint)
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.5))
                    }

                    // Actual text field
                    TextField("Search...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 24, weight: .regular))
                        .focused($isSearchFieldFocused)
                        .onSubmit { viewModel.execute() }
                        .onKeyPress(.tab) {
                            viewModel.acceptAutocomplete()
                            return .handled
                        }
                        .onKeyPress(.upArrow) {
                            viewModel.moveUp()
                            return .handled
                        }
                        .onKeyPress(.downArrow) {
                            viewModel.moveDown()
                            return .handled
                        }
                        .onKeyPress(.escape) {
                            viewModel.dismiss()
                            return .handled
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var resultsList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, result in
                        SearchResultRow(
                            result: result,
                            isSelected: index == viewModel.selectedIndex
                        )
                        .id(result.id)
                        .onTapGesture {
                            viewModel.selectedIndex = index
                            viewModel.execute()
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .id(viewModel.searchText)
            .onChange(of: viewModel.selectedIndex) { _, newIndex in
                if newIndex < viewModel.results.count {
                    withAnimation(.easeOut(duration: 0.12)) {
                        proxy.scrollTo(viewModel.results[newIndex].id, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct SearchResultRow: View {
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

// MARK: - ParamTextField (NSTextField wrapper for backspace detection)

struct ParamTextField: NSViewRepresentable {
    @Binding var text: String
    var onBackspaceWhenEmpty: () -> Void
    var onEscape: () -> Void
    var onSubmit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = BackspaceDetectingTextField()
        textField.delegate = context.coordinator
        textField.onBackspaceWhenEmpty = onBackspaceWhenEmpty
        textField.onEscape = onEscape
        textField.font = NSFont.systemFont(ofSize: 24, weight: .regular)
        textField.isBordered = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.placeholderString = "Enter parameter..."

        // Focus the text field after a short delay
        DispatchQueue.main.async {
            textField.window?.makeFirstResponder(textField)
        }

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        if let tf = nsView as? BackspaceDetectingTextField {
            tf.onBackspaceWhenEmpty = onBackspaceWhenEmpty
            tf.onEscape = onEscape
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: ParamTextField

        init(_ parent: ParamTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                parent.onSubmit()
                return true
            }
            if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
                if parent.text.isEmpty {
                    parent.onBackspaceWhenEmpty()
                    return true
                }
            }
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.onEscape()
                return true
            }
            return false
        }
    }
}

private class BackspaceDetectingTextField: NSTextField {
    var onBackspaceWhenEmpty: (() -> Void)?
    var onEscape: (() -> Void)?
}
