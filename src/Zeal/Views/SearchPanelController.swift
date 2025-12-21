import AppKit
import SwiftUI
import Combine



// MARK: - Panel Controller



@MainActor
final class SearchPanelController: NSObject, NSWindowDelegate {
    private var panel: NSPanel?
    private var viewModel: SearchViewModel?

    var isVisible: Bool {
        panel?.isVisible == true
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if panel == nil {
            viewModel = SearchViewModel()
            viewModel?.onDismiss = { [weak self] in self?.hide() }
            panel = createPanel()
        }

        viewModel?.reset()
        centerPanel()
        NSApp.activate(ignoringOtherApps: true)
        panel?.makeKeyAndOrderFront(nil)
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func windowDidResignKey(_ notification: Notification) {
        hide()
    }

    private func createPanel() -> NSPanel {
        let panel = KeyablePanel(
            contentRect: .zero,
            styleMask: [.borderless], // Standard for Spotlight-like panels
            backing: .buffered,
            defer: false
        )

        panel.delegate = self
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.becomesKeyOnlyIfNeeded = false

        if let viewModel {
            panel.contentView = NSHostingView(rootView: SearchView(viewModel: viewModel))
        }

        return panel
    }

    private func centerPanel() {
        guard let panel else { return }
        
        // Find the screen containing the mouse cursor, fallback to main or first screen
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } 
            ?? NSScreen.main 
            ?? NSScreen.screens.first
            
        guard let targetScreen = screen else { return }
        
        let frame = targetScreen.frame
        // Use known panel dimensions (width: 580, initial height: 68)
        let panelWidth: CGFloat = 580
        let panelHeight: CGFloat = 68
        
        // Position: horizontally centered
        // Vertically: ~20% from the top (Spotlight style)
        let origin = NSPoint(
            x: frame.midX - panelWidth / 2,
            y: frame.maxY - (frame.height * 0.20) - panelHeight
        )
        
        let targetFrame = NSRect(origin: origin, size: NSSize(width: panelWidth, height: panelHeight))
        panel.setFrame(targetFrame, display: true)
    }
}

// MARK: - View Model

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedIndex = 0
    @Published var lockedResult: SearchResult?
    @Published var paramText = ""
    @Published private(set) var results: [SearchResult] = []

    var onDismiss: (() -> Void)?

    private let store: KeywordStore
    private let appSearch: AppSearchService
    private var cancellables = Set<AnyCancellable>()

    init(store: KeywordStore = .shared, appSearch: AppSearchService = .shared) {
        self.store = store
        self.appSearch = appSearch

        // Update results when searchText changes
        $searchText
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.selectedIndex = 0
                self?.updateResults()
                self?.appSearch.search(text)
            }
            .store(in: &cancellables)

        // Update results when lockedResult changes
        $lockedResult
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateResults()
            }
            .store(in: &cancellables)

        // Update results when store keywords change
        store.$keywords
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateResults()
            }
            .store(in: &cancellables)

        // Update results when app search results change
        appSearch.$results
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateResults()
            }
            .store(in: &cancellables)

        updateResults()
    }

    private func updateResults() {
        if lockedResult != nil {
            results = []
            return
        }

        // Get keyword results
        let keywords = store.search(searchText).map { SearchResult.keyword($0) }

        // Get app results
        let apps = appSearch.results.map { SearchResult.app($0) }
        
        // Zeabur results
        Task {
            let zeaburResults = await ZeaburSearchProvider.search(query: searchText)
            
            // Map Zeabur internal results to our SearchResult enum
            // Ideally ZeaburSearchProvider should return SearchResult type directly,
            // but for now let's assume it returns internal struct or [SearchResult].
            // Wait, ZeaburSearchProvider.search returns [SearchResult] based on my implementation.
            
            let combined = keywords + zeaburResults + apps
            
            await MainActor.run {
                self.results = combined
            }
        }
    }

    /// Returns the autocomplete hint showing the full title with user input preserved
    var autocompleteHint: String? {
        guard !searchText.isEmpty,
              selectedIndex < results.count else { return nil }

        let result = results[selectedIndex]
        let title = result.title

        // Check if the title starts with the search text (case-insensitive)
        guard title.lowercased().hasPrefix(searchText.lowercased()) else { return nil }

        // Return the full title preserving user's typed case + remaining characters
        return searchText + title.dropFirst(searchText.count)
    }

    func reset() {
        searchText = ""
        selectedIndex = 0
        lockedResult = nil
        paramText = ""
        appSearch.stop()
    }

    func selectCurrent() {
        guard lockedResult == nil,
              selectedIndex < results.count else { return }

        let result = results[selectedIndex]

        // Only lock if it's a parameterized keyword
        if result.isParameterized {
            lockedResult = result
            searchText = ""
            paramText = ""
            selectedIndex = 0
        }
    }

    /// Accept the autocomplete suggestion and select/execute
    func acceptAutocomplete() {
        guard selectedIndex < results.count else { return }
        let result = results[selectedIndex]

        guard !result.isParameterized else {
            selectCurrent()
            return
        }

        result.execute(param: nil)
        onDismiss?()
    }

    func unlock() {
        lockedResult = nil
        searchText = ""
        paramText = ""
    }

    func moveUp() {
        guard selectedIndex > 0 else { return }
        selectedIndex -= 1
    }

    func moveDown() {
        guard selectedIndex < results.count - 1 else { return }
        selectedIndex += 1
    }

    func execute() {
        if let result = lockedResult {
            executeLocked(result)
            return
        }
        executeSelected()
    }

    private func executeLocked(_ result: SearchResult) {
        let param = paramText.isEmpty ? nil : paramText
        guard !result.isParameterized || param != nil else { return }

        result.execute(param: param)
        onDismiss?()
    }

    private func executeSelected() {
        guard selectedIndex < results.count else { return }
        let result = results[selectedIndex]

        guard !result.isParameterized else {
            selectCurrent()
            return
        }

        result.execute(param: nil)
        onDismiss?()
    }

    func dismiss() {
        appSearch.stop()
        onDismiss?()
    }

    // For locked state display
    var lockedTitle: String? {
        switch lockedResult {
        case .keyword(let keyword):
            return keyword.shortcut
        default:
            return nil
        }
    }
}
