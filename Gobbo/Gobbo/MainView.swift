import SwiftUI

struct MainView: View {
    @Binding var prompt: Prompt

    @State private var offset: CGFloat = 0
    @State private var isEditing: Bool = false
    @State private var title: String = ""
    @State private var textContent: String = ""
    @State private var editingTitle: String = ""
    @State private var editingText: String = ""
    @State private var showStartTime: Date = Date()
    @State private var showEndTime: Date = Date().addingTimeInterval(600)
    @State private var remainingTime: TimeInterval = 0
    @State private var currentTime: Date = Date()
    @State private var timeUpdateTimer: Timer?
    @State private var showMirroringMessage: Bool = false
    @State private var shouldOpenEditView: Bool = false
    @State private var showTutorialAlert: Bool = false
    @State private var currentLineIndex: Int = 0
    @State private var timer: Timer?
    @State private var lines: [String] = []

    // New state variables for autoscroll and karaoke
    @State private var isAutoScrollEnabled: Bool = false
    @State private var isKaraokeEnabled: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // Top bar with autoscroll and karaoke toggles
                HStack {
                    ToggleButton(
                        title: "Autoscroll",
                        isEnabled: $isAutoScrollEnabled,
                        action: toggleAutoScroll
                    )

                    ToggleButton(
                        title: "Karaoke",
                        isEnabled: $isKaraokeEnabled,
                        action: toggleKaraoke
                    )
                }
                .padding()

                // Title
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                // Scrollable karaoke text with tap detection
                ScrollViewReader { scrollView in
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(0..<lines.count, id: \.self) { index in
                                    Text(lines[index])
                                        .foregroundColor(index == currentLineIndex ? .blue : .white)
                                        .id(index)
                                        .padding()
                                }
                            }
                            .contentShape(Rectangle()) // Estende l'area sensibile al tocco
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let tapX = value.location.x
                                        let screenMidX = geometry.size.width / 2
                                        
                                        if !isAutoScrollEnabled && !isKaraokeEnabled {
                                            if tapX < screenMidX {
                                                // Tap sinistra -> Vai su
                                                if currentLineIndex > 0 {
                                                    currentLineIndex -= 1
                                                }
                                            } else {
                                                // Tap destra -> Vai giù
                                                if currentLineIndex < lines.count - 1 {
                                                    currentLineIndex += 1
                                                }
                                            }
                                        }
                                    }
                            )
                        }
                        .onChange(of: currentLineIndex) { index in
                            withAnimation {
                                scrollView.scrollTo(index, anchor: .top)
                            }
                        }
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            loadData()
            updateViewWithPrompt()
        }
        .onDisappear {
            stopTimers()
        }

    }

    // MARK: - Toggle Functions

    private func toggleAutoScroll() {
        if isAutoScrollEnabled {
            stopTimers()
        } else {
            startTimers()
        }
    }

    private func toggleKaraoke() {
        if isKaraokeEnabled {
            startKaraokeTimer()
        } else {
            stopKaraokeTimer()
        }
    }

    // MARK: - Timer Management

    private func startTimers() {
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
            updateRemainingTime()
        }
    }
    
    private func updateViewWithPrompt() {
        title = prompt.title
        textContent = prompt.content
        lines = preprocessTextContent(prompt.content)
    }

    private func updateRemainingTime() {
        remainingTime = max(showEndTime.timeIntervalSinceNow, 0) // Ensures remaining time is never negative
    }

    private func preprocessTextContent(_ content: String) -> [String] {
        return content
            .components(separatedBy: .newlines) // Split content into lines based on newlines
            .filter { !$0.isEmpty }             // Remove any empty lines
    }
    

    
    private func loadData() {
        if let savedTitle = UserDefaults.standard.string(forKey: "title-\(prompt.id.uuidString)") {
            title = savedTitle
        }
        if let savedContent = UserDefaults.standard.string(forKey: "content-\(prompt.id.uuidString)") {
            textContent = savedContent
            lines = preprocessTextContent(savedContent) // Update lines after loading content
        }
        if let savedStartTime = UserDefaults.standard.object(forKey: "startTime-\(prompt.id.uuidString)") as? Date {
            showStartTime = savedStartTime
        }
        if let savedEndTime = UserDefaults.standard.object(forKey: "endTime-\(prompt.id.uuidString)") as? Date {
            showEndTime = savedEndTime
        }
        updateRemainingTime() // Update remaining time after loading
    }


    private func stopTimers() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
    }

    private func startKaraokeTimer() {
        stopKaraokeTimer() // Stop any existing timers
        
        // Calculate durations dynamically for each line
        let durations = lines.map { line -> TimeInterval in
            let wordCount = line.split(separator: " ").count
            let baseTimePerWord: TimeInterval = 0.5 // Adjust base time per word as needed
            return max(TimeInterval(wordCount) * baseTimePerWord, 1.0) // Ensure minimum duration
        }
        
        var currentIndex = currentLineIndex
        timer = Timer.scheduledTimer(withTimeInterval: durations[currentIndex], repeats: false) { _ in
            advanceKaraokeLine(durations: durations)
        }
    }

    // Helper function to advance the karaoke line
    private func advanceKaraokeLine(durations: [TimeInterval]) {
        if currentLineIndex < lines.count - 1 {
            currentLineIndex += 1
            
            // Start a new timer for the next line's duration
            timer = Timer.scheduledTimer(withTimeInterval: durations[currentLineIndex], repeats: false) { _ in
                advanceKaraokeLine(durations: durations)
            }
        } else {
            stopKaraokeTimer() // Stop when the last line is reached
        }
    }


    private func stopKaraokeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTap(location: CGPoint, in screenSize: CGSize) {
        let screenMidX = screenSize.width / 2
        
        if isAutoScrollEnabled || isKaraokeEnabled {
            return // Do nothing if autoscroll or karaoke are enabled
        }

        if location.x < screenMidX {
            // Tapped on the left - move up
            if currentLineIndex > 0 {
                currentLineIndex -= 1
            }
        } else {
            // Tapped on the right - move down
            if currentLineIndex < lines.count - 1 {
                currentLineIndex += 1
            }
        }
    }

}

// MARK: - ToggleButton View

struct ToggleButton: View {
    let title: String
    @Binding var isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            isEnabled.toggle()
            action()
        }) {
            HStack {
                Text(title)
                Image(systemName: isEnabled ? "checkmark.square" : "square")
            }
            .foregroundColor(.blue)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
}


