//
//  TimerManager.swift
//  Gobbo
//
//  Created by Lorenzo Mazza on 11/12/24.
//

import Foundation

// TimerManager handles the management of the timer for tracking time
// and calculating the remaining time between a given start and end time.
class TimerManager: ObservableObject {
    // Published properties allow views to observe and react to changes.
    @Published var currentTime: Date = Date() // The current time, updated every second.
    @Published var remainingTime: TimeInterval = 0 // The remaining time (in seconds) until the end time.

    // Private property to store the timer reference.
    private var timer: Timer?

    // Starts the timer and begins counting down from the given end time.
    func start(startTime: Date, endTime: Date) {
        stop() // Stop any existing timer before starting a new one.

        // Calculate the initial remaining time from the end time and current time.
        remainingTime = max(endTime.timeIntervalSinceNow, 0)

        // Set up a new timer that repeats every second.
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Update the current time to the current date every second.
            self.currentTime = Date()

            // Recalculate the remaining time until the end time.
            self.remainingTime = max(endTime.timeIntervalSinceNow, 0)
        }
    }

    // Stops the timer and invalidates it.
    func stop() {
        timer?.invalidate() // Stops the timer if it's running.
        timer = nil // Resets the timer to nil.
    }
}
