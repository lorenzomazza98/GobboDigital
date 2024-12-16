import SwiftUI

// Defines a `Prompt` model that conforms to `Identifiable`, `Codable`, and `Equatable` protocols.
// - `Identifiable`: Allows SwiftUI to uniquely identify each prompt in a list by its `id`.
// - `Codable`: Enables encoding/decoding to/from JSON for persistence.
// - `Equatable`: Enables comparison of `Prompt` objects for equality.
struct Prompt: Identifiable, Codable, Equatable {
    let id: UUID // Unique identifier for each prompt.
    var title: String // The title of the prompt.
    var content: String // The content or body of the prompt.

    // Initializer to create a new `Prompt` with optional `id` (defaults to a new UUID).
    init(id: UUID = UUID(), title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
}

// A SwiftUI view that displays a list of prompts.
// Users can navigate to a detailed view for each prompt or add/delete prompts.
struct PromptsListView: View {
    @ObservedObject var manager: PromptManager // Manages the list of prompts and provides updates to the view.
    @State private var isAddingPrompt = false // Tracks whether the "Add Prompt" view is presented.

    var body: some View {
        NavigationView {
            // A list displaying all prompts from the manager.
            List {
                // Loops through all prompts using bindings for two-way data updates.
                ForEach($manager.prompts) { $prompt in
                    // Each list item is a navigation link to the `MainView` for the selected prompt.
                    NavigationLink(destination: MainView(prompt: $prompt)) {
                        Text(prompt.title) // Displays the title of the prompt in the list.
                    }
                }
                .onDelete(perform: manager.deletePrompts) // Enables swipe-to-delete functionality.
            }
            .navigationBarTitle("Your Prompts") // Sets the title of the navigation bar.
            .toolbar {
                // Adds a toolbar button to create a new prompt.
                Button(action: { isAddingPrompt = true }) {
                    Label("Add Prompt", systemImage: "plus") // Uses a plus icon for the button.
                }
            }
            // Presents the `AddPromptView` as a modal sheet when `isAddingPrompt` is true.
            .sheet(isPresented: $isAddingPrompt) {
                AddPromptView(manager: manager, isPresented: $isAddingPrompt)
            }
        }
    }
}
