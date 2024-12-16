//
//  PromptManager.swift
//  Gobbo
//
//  Created by Lorenzo Mazza on 11/12/24.
//

import Foundation

// A class to manage the list of prompts used in the application.
// Implements the `ObservableObject` protocol to allow SwiftUI views to react to changes in the prompts list.
class PromptManager: ObservableObject {
    @Published var prompts: [Prompt] = [] // List of prompts that the app uses and observes for changes.

    private let promptsKey = "savedPrompts" // Key used to store and retrieve prompts from UserDefaults.

    // Initializes the manager and loads any saved prompts from persistent storage.
    init() {
        loadPrompts()
    }

    // Adds a new prompt to the list and saves the updated list to storage.
    func addPrompt(_ prompt: Prompt) {
        prompts.append(prompt) // Add the new prompt.
        savePrompts() // Save the updated list.
    }

    // Deletes prompts at specified offsets and saves the updated list to storage.
    func deletePrompts(at offsets: IndexSet) {
        prompts.remove(atOffsets: offsets) // Remove the prompts at the specified indices.
        savePrompts() // Save the updated list.
    }

    // Updates an existing prompt in the list and saves the updated list to storage.
    func updatePrompt(_ prompt: Prompt) {
        // Find the index of the prompt with the matching ID.
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt // Update the prompt at the found index.
            savePrompts() // Save the updated list.
        }
    }

    // Encodes the list of prompts to JSON and saves it to UserDefaults.
    private func savePrompts() {
        if let encoded = try? JSONEncoder().encode(prompts) { // Try to encode the prompts array.
            UserDefaults.standard.set(encoded, forKey: promptsKey) // Save the encoded data to UserDefaults.
        }
    }

    // Loads prompts from UserDefaults, decoding the stored JSON data into a list of prompts.
    private func loadPrompts() {
        // Retrieve the saved data from UserDefaults.
        if let savedData = UserDefaults.standard.data(forKey: promptsKey),
           let decoded = try? JSONDecoder().decode([Prompt].self, from: savedData) { // Try to decode the data.
            prompts = decoded // Update the prompts list with the decoded data.
        }
    }
}
