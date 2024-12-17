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
    
    // Formatter for displaying the current time.
     private var currentTimeFormatter: DateFormatter {
         let formatter = DateFormatter()
         formatter.dateFormat = "HH:mm"
         return formatter
     }
    
    // Define a computed property to handle the image name based on the timer state
    private var customTimerImageName: String {
        isCustomTimerRunning ? "pause.fill" : "play.fill"
    }
    
    //Stopwatch
    @State private var isTimerRunning: Bool = false
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var isCustomTimerRunning: Bool = false
    @State private var customStartTime = Date()  // Tempo di inizio
    @State private var customElapsedTime: TimeInterval = 0
    @State private var customTimeUpdateTimer: Timer?
    @State private var customCurrentTime: Date = Date(timeIntervalSince1970: 0)



    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

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
                    .accessibilityHint("Tap to view the tutorial with usage instructions.")
                    .padding(.trailing, 16)

                    // Edit button to enable editing mode.
                    Button("Edit") {
                        editingTitle = title
                        editingText = textContent
                        isEditing = true
                    }
                    .font(.title2)
                    .foregroundColor(.blue)
                    .accessibilityLabel("Edit Content")
                    .accessibilityHint("Tap to edit the title and text content.")
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Top bar with Information and Edit buttons")

                // Title
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .accessibilityLabel("Content Title: \(title)")

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
                                        .accessibilityLabel("Line \(index + 1): \(lines[index])")
                                        .accessibilityHint(index == currentLineIndex ? "Currently highlighted" : "")
                                        
                                }
                            }
                            .contentShape(Rectangle()) // Extends tap-sensitive area
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let tapX = value.location.x
                                        let screenMidX = geometry.size.width / 2
                                        
                                        if !isAutoScrollEnabled && !isKaraokeEnabled {
                                            if tapX < screenMidX {
                                                // Tap left -> Go up
                                                if currentLineIndex > 0 {
                                                    currentLineIndex -= 1
                                                }
                                            } else {
                                                // Tap right -> Go down
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
                .accessibilityLabel("Scrollable content area")
                .accessibilityHint("Swipe up or down to scroll, or tap left and right for navigation.")

                Spacer()
                
                Divider()
                

                
                HStack(spacing: 30) {
                    // Sezione Tempo Corrente
                    HStack {
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
                        .padding(.bottom, 30)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Current Time Display")
                        .accessibilityHint("Shows the current time in hours and minutes.")
                    }

                    Divider()
                    
                    // Sezione Timer Personalizzato
                    HStack {
                        Text("\(formatTime(customCurrentTime))")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()

                        HStack(spacing: 20) {
                            Button(action: toggleCustomTimer) {
                                Image(systemName: customTimerImageName)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(isCustomTimerRunning ? Color.red : Color.green)
                                    .cornerRadius(10)
                            }
                            .accessibilityLabel(isCustomTimerRunning ? "Stop Timer" : "Start Timer")

                            Button(action: resetCustomTimer) {
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            .accessibilityLabel("Reset Timer")
                        }
                        .padding(.top, 10)
                    }
                    
                    Divider()

                    // Sezione Karaoke Mode
                    ToggleButton(
                        title: "Karaoke Mode",
                        isEnabledKaraoke: $isKaraokeEnabled,
                        isEnabledAutoscroll: $isAutoScrollEnabled,
                        action1: toggleKaraoke,
                        action2: toggleAutoScroll
                    )
                    .accessibilityLabel("Karaoke Mode Toggle")
                    .accessibilityHint("Tap to enable or disable karaoke mode.")
                }
                .padding(.horizontal, 20) // Aggiungi una spaziatura laterale coerente per evitare che gli elementi tocchino i bordi dello schermo
                .padding(.top,30)
                // Timer view showing the current time.
                
                

                Spacer()
                
                


                // Top bar with autoscroll and karaoke toggles
                    /*
                    ToggleButton(
                        title: "Autoscroll",
                        isEnabled: $isAutoScrollEnabled,
                        action: toggleAutoScroll
                    )
                    .accessibilityLabel("Autoscroll Toggle")
                    .accessibilityHint("Tap to enable or disable automatic scrolling.")
*/
                    
            }
        }
        .alert("Tutorial", isPresented: $showTutorialAlert) {
            Button("Close", role: .cancel) {}
                .accessibilityLabel("Close Tutorial")
                .accessibilityHint("Tap to dismiss the tutorial message.")
        } message: {
            Text("""
            How to Use the App:
            
            Edit Content: Tap the "Edit" button at the top to modify the title and text content.
            
            Navigate Text: Tap the left or right side of the screen to move between lines of text.
            
            Current Time Display: The current time is shown at the bottom, updating every minute.
            
            Karaoke Mode: Enable "Karaoke Mode" to automatically highlight the current line in sync with the timer.
            
            Timer: A custom timer is available to track specific events or durations.
            
            It is recommended to use screen mirroring for optimal display during use.
            """)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Tutorial Instructions")
        }
        .onAppear {
            loadData() // Load saved data when the view appears.
            startTimers() // Start the timers for time updates.
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
            .accessibilityLabel("Edit Content View")
            .accessibilityHint("Modify the title and text content here, then save or cancel changes.")
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
    
    //stopwatch timer
    
    // Funzione per formattare il tempo
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss" // Formato minuti:secondi
        return formatter.string(from: date)
    }
    
    private func toggleCustomTimer() {
        if isCustomTimerRunning {
            // Stop the custom timer
            isCustomTimerRunning = false
            customElapsedTime += Date().timeIntervalSince(customStartTime ?? Date())
            stopCustomTimer()
        } else {
            // Start the custom timer
            isCustomTimerRunning = true
            customStartTime = Date()
            startCustomTimer()
        }
    }


    private func resetCustomTimer() {
        isCustomTimerRunning = false
        customElapsedTime = 0
        customStartTime = Date() // Inizializza di nuovo il tempo di inizio
        customCurrentTime = Date(timeIntervalSince1970: 0) // Imposta a zero
        stopCustomTimer()
    }



    private func startCustomTimer() {
        customTimeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let currentElapsedTime = self.customElapsedTime + Date().timeIntervalSince(self.customStartTime ?? Date())
            self.customCurrentTime = Date(timeIntervalSince1970: currentElapsedTime)
        }
    }

    private func stopCustomTimer() {
        customTimeUpdateTimer?.invalidate()
        customTimeUpdateTimer = nil
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
    
    private func saveData() {
            UserDefaults.standard.setValue(title, forKey: "title-\(prompt.id.uuidString)")
            UserDefaults.standard.setValue(textContent, forKey: "content-\(prompt.id.uuidString)")
            lines = textContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
        }

}

// MARK: - ToggleButton View

struct ToggleButton: View {
    let title: String
    @Binding var isEnabledKaraoke: Bool
    @Binding var isEnabledAutoscroll: Bool
    let action1: () -> Void
    let action2: () -> Void

    var body: some View {
        Button(action: {
            isEnabledKaraoke.toggle()
            isEnabledAutoscroll.toggle()

            action1()
            action2()
        }) {
            HStack {
                Text(title)
                Image(systemName: isEnabledKaraoke && isEnabledAutoscroll ? "checkmark.square" : "square")
            }
            .foregroundColor(.blue)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
}


