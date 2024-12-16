//
//  AddPromptView.swift
//  Gobbo
//
//  Created by Lorenzo Mazza on 11/12/24.
//

import SwiftUI

// This struct defines the view for adding a new prompt. It allows the user to input a title and content,
// and save the new prompt into the app's data model.
struct AddPromptView: View {
    // `manager` is an observed object of type `PromptManager`. It is responsible for managing the list of prompts
    // and provides the logic for adding, deleting, or updating prompts.
    @ObservedObject var manager: PromptManager
    
    // `isPresented` is a binding variable that tracks whether the `AddPromptView` is currently being displayed.
    // When this variable is set to `false`, the view is dismissed.
    @Binding var isPresented: Bool

    // `title` and `content` are state variables that hold the user's input for the title and content of the new prompt.
    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {
        // A navigation view is used to provide a navigation bar and structure to the interface.
        NavigationView {
            // A form is used to organize input fields into sections, creating a user-friendly interface.
            Form {
                // First section: Title input
                Section(header: Text("Title")) {
                    // A text field allows the user to enter the title of the new prompt.
                    // The input is bound to the `title` state variable.
                    TextField("Enter title", text: $title)
                }
                // Second section: Content input
                Section(header: Text("Content")) {
                    // A text editor allows the user to input longer, multi-line content for the new prompt.
                    // It is bound to the `content` state variable and styled with a fixed height and border.
                    TextEditor(text: $content)
                        .frame(height: 200) // Sets a fixed height for the editor.
                        .border(Color.gray, width: 1) // Adds a gray border around the editor.
                }
            }
            .navigationBarTitle("New Prompt") // Sets the title of the navigation bar.
            .navigationBarItems(
                // Left navigation bar button: Cancel
                leading: Button("Cancel") {
                    // When pressed, the `isPresented` binding is set to `false`, dismissing the view.
                    isPresented = false
                },
                // Right navigation bar button: Save
                trailing: Button("Save") {
                    // When pressed, a new prompt is created with the input `title` and `content`,
                    // and added to the `manager` using its `addPrompt` method.
                    manager.addPrompt(Prompt(title: title, content: content))
                    // Dismisses the view after saving the new prompt.
                    isPresented = false
                }
                // The Save button is disabled if either the `title` or `content` is empty,
                // preventing the creation of invalid prompts.
                .disabled(title.isEmpty || content.isEmpty)
            )
        }
    }
}
