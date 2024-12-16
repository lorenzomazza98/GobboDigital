import SwiftUI

// A view for editing text content, titles, and time ranges.
// It allows the user to make changes and save or cancel their edits.
struct EditTextView: View {
    // Bindings are used to connect this view's properties to external state.
    // Changes made here will reflect in the parent view, and vice versa.
    @Binding var title: String      // The title to be edited.
    @Binding var text: String       // The main text content to be edited.
    @Binding var startTime: Date    // The start time for the content.
    @Binding var endTime: Date      // The end time for the content.

    // Callback closures for save and cancel actions, allowing this view
    // to notify the parent view when the user completes or discards their edits.
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        // The main container for the view, providing navigation capabilities.
        NavigationView {
            // A form layout to structure input fields in sections.
            Form {
                // Section for editing the title.
                Section(header: Text("Edit Title")) {
                    TextField("Enter title", text: $title) // Text input for the title.
                        .accessibilityLabel("Title Input") // Accessibility: describes the input field.
                        .accessibilityHint("Input field for title") // Accessibility: explains its purpose.
                }

                // Section for editing the main text content.
                Section(header: Text("Edit Text")) {
                    TextEditor(text: $text) // A multi-line text input area.
                        .frame(minHeight: 200) // Sets a minimum height for comfortable editing.
                        .border(Color.gray, width: 1) // Adds a border for visual distinction.
                        .accessibilityLabel("Text Editor") // Accessibility label for screen readers.
                        .accessibilityHint("Input field for text content") // Accessibility hint.
                }

                // Section for editing the start and end time.
                Section(header: Text("Time Range")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        // A picker for selecting the start time, limited to hours and minutes.
                        .accessibilityLabel("Start Time Picker") // Accessibility label for the picker.
                        .accessibilityHint("Set start time") // Accessibility hint.
                    
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        // A picker for selecting the end time, limited to hours and minutes.
                        .accessibilityLabel("End Time Picker") // Accessibility label for the picker.
                        .accessibilityHint("Set end time") // Accessibility hint.
                }
            }
            .navigationBarTitle("Edit Content") // Sets the title of the navigation bar.
            .navigationBarItems(
                // A cancel button on the leading side of the navigation bar.
                leading: Button("Cancel") {
                    onCancel() // Calls the cancel action.
                },
                // A save button on the trailing side of the navigation bar.
                trailing: Button("Save") {
                    onSave() // Calls the save action.
                }
                // The save button is disabled if either the title or text is empty.
                .disabled(title.isEmpty || text.isEmpty)
            )
        }
    }
}
