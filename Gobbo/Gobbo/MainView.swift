import SwiftUI

struct MainView: View {
    @Binding var prompt: Prompt // The main data object containing title and content to be displayed.

    // State variables to manage various aspects of the view's behavior and data.
    @State private var offset: CGFloat = 0 // Used for tracking scroll offset if needed.
    @State private var isEditing: Bool = false // Determines whether the edit mode is active.
    @State private var title: String = "" // The title of the text content.
    @State private var textContent: String = "" // The main text content.
    @State private var editingTitle: String = "" // Temporary title used during editing.
    @State private var editingText: String = "" // Temporary text content used during editing.
    @State private var showStartTime: Date = Date() // The start time for the session.
    @State private var showEndTime: Date = Date().addingTimeInterval(600) // The end time for the session, defaulted to 10 minutes later.
    @State private var remainingTime: TimeInterval = 0 // The remaining time for the session.
    @State private var currentTime: Date = Date() // The current time, updated regularly.
    @State private var timeUpdateTimer: Timer? // Timer for updating the current time and remaining time.
    @State private var showMirroringMessage: Bool = false // Determines whether a mirroring message is displayed.
    @State private var shouldOpenEditView: Bool = false // Controls whether the edit view should open.
    @State private var showTutorialAlert: Bool = false // Controls whether the tutorial alert is displayed.
    @State private var currentLineIndex: Int = 0 // The index of the currently highlighted line.
    @State private var timer: Timer? // Timer for automatically transitioning between lines (karaoke effect).
    @State private var lines: [String] = [] // Array of lines for displaying the text content.

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Sets the background color to black.

            VStack {
                // Top bar with info and edit buttons.
                HStack {
                    Spacer()

                    // Info button to show the tutorial alert.
                    Button(action: {
                        showTutorialAlert = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Information")
                    .accessibilityHint("Tap to view the tutorial.")
                    .padding(.trailing, 16)


                    // Edit button to enable editing mode.
                    Button("Edit") {
                        editingTitle = title
                        editingText = textContent
                        isEditing = true
                    }
                    .font(.title2)
                    .foregroundColor(.blue)
                    .accessibilityLabel("Edit content")
                    .accessibilityHint("Tap to modify the title and text content.")
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Top bar with Info and Edit buttons")

                // Title of the text content.
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Divider().background(Color.white.opacity(0.5)) // Divider line.

                Spacer()

                // Scrollable text view with karaoke-like highlighting.
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(0..<lines.count, id: \.self) { index in
                                Text(lines[index])
                                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                    .lineSpacing(10)
                                    .foregroundColor(index == currentLineIndex ? .blue : .white)
                                    .padding(.horizontal, 30)
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel("Scrollable text area with karaoke-style highlighting")
                                    .animation(.easeInOut(duration: 0.3), value: currentLineIndex) // Smooth transition between lines.
                                    .id(index) // Assign ID for scroll tracking.
                                    .cornerRadius(8)
                                    .accessibilityLabel("Line \(index + 1): \(lines[index])")
                                    .accessibilityValue(index == currentLineIndex ? "Currently highlighted" : "Not highlighted")
                                    .background(index == currentLineIndex ? Color.black.opacity(0.8) : Color.clear) // Highlight background.
                            }
                        }
                    }
                    .onChange(of: currentLineIndex) { index in
                        // Scroll to the current line when the index changes.
                        withAnimation {
                            scrollView.scrollTo(index, anchor: .top)
                        }
                    }
                    .padding(.bottom, 30)
                }

                Spacer()

                // Timer view showing the current time.
                HStack(spacing: 64) {
                    TimerCircleView(
                        title: """
                        CURRENT
                        TIME
                        """,
                        iconLeft: "clock",
                        iconRight: "",
                        timeRemaining: currentTimeFormatter.string(from: currentTime),
                        color: .blue,
                        circleSize: 200
                    )
                }
                .padding(.bottom, 30)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Timer section showing the current time");

                Spacer()
            }
        }
        .alert("Tutorial", isPresented: $showTutorialAlert) {
            Button("Close", role: .cancel) {}
                .accessibilityLabel("Close tutorial")
        } message: {
            Text("""
            Here's how to use the app:

            1. Use the Edit button to modify the content.
            2. Scroll through the text by swiping up or down, or tapping on the left/right of the screen.
            3. View the timer at the bottom that shows the current hour.

            It is recommended to use screen mirroring while using this app.
            """)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Tutorial instructions")
        }
        .onAppear {
            loadData() // Load saved data when the view appears.
            updateViewWithPrompt() // Update the view with the provided prompt.
            startTimers() // Start the timers for time updates.
            startKaraokeTimer() // Start the karaoke timer for transitioning lines.
        }
        .onDisappear {
            saveData() // Save data when the view disappears.
            stopTimers() // Stop time-related timers.
            stopKaraokeTimer() // Stop the karaoke timer.
        }
        .sheet(isPresented: $isEditing) {
            // Edit view for modifying title and content.
            EditTextView(
                title: $editingTitle,
                text: $editingText,
                startTime: $showStartTime,
                endTime: $showEndTime,
                onSave: {
                    // Save changes and update lines with empty line separation.
                    lines = preprocessTextContent(editingText)
                    title = editingTitle
                    isEditing = false
                    updateRemainingTime()
                    showMirroringMessage = true
                },
                onCancel: {
                    isEditing = false
                    showMirroringMessage = true
                }
            )
        }
    }

    // Formatter for displaying the current time.
    private var currentTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    // Save the current title and content to UserDefaults.
    private func saveData() {
        UserDefaults.standard.set(prompt.title, forKey: "title-\(prompt.id.uuidString)")
        UserDefaults.standard.set(prompt.content, forKey: "content-\(prompt.id.uuidString)")
    }

    // Load the saved title, content, start time, and end time from UserDefaults.
    private func loadData() {
        if let savedTitle = UserDefaults.standard.string(forKey: "title") {
            title = savedTitle
        }
        if let savedTextContent = UserDefaults.standard.string(forKey: "textContent") {
            textContent = savedTextContent
        }
        if let savedStartTime = UserDefaults.standard.object(forKey: "startTime") as? Date {
            showStartTime = savedStartTime
        }
        if let savedEndTime = UserDefaults.standard.object(forKey: "endTime") as? Date {
            showEndTime = savedEndTime
        }
        updateRemainingTime()
    }

    // Update the remaining time for the session.
    private func updateRemainingTime() {
        remainingTime = max(showEndTime.timeIntervalSinceNow, 0)
    }

    // Start a timer to update the current time and remaining time every second.
    private func startTimers() {
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
            updateRemainingTime()
        }
    }

    // Stop the time update timer.
    private func stopTimers() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
    }

    // Start a timer for transitioning lines in a karaoke-style effect.
    private func startKaraokeTimer() {
        let totalDuration = showEndTime.timeIntervalSince(showStartTime) // Calculate the total duration.
        let lineDuration = totalDuration / Double(lines.count) // Calculate the duration per line.

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let elapsedTime = Date().timeIntervalSince(showStartTime)
            let newLineIndex = Int(elapsedTime / lineDuration) // Determine the current line index.
            if newLineIndex < lines.count && newLineIndex != currentLineIndex {
                currentLineIndex = newLineIndex
            }
        }
    }

    // Stop the karaoke timer.
    private func stopKaraokeTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Preprocess the text content to split into lines and add empty lines between them.
    func preprocessTextContent(_ text: String) -> [String] {
        let lines = text.split(separator: "\n")
        var processedLines: [String] = []

        for line in lines {
            processedLines.append(String(line))
            processedLines.append("") // Add an empty line.
        }

        return processedLines
    }

    // Update the view with the data from the provided prompt.
    private func updateViewWithPrompt() {
        title = prompt.title
        lines = preprocessTextContent(prompt.content)
    }
}
