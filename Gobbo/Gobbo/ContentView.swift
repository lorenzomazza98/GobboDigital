import SwiftUI

// The main entry point for the application.
// The `@main` attribute marks this struct as the application's entry point.
@main
struct MyApp: App {
    // `@StateObject` initializes an instance of `PromptManager` that will be observed and shared across the app.
    // It ensures the manager's lifecycle is tied to the app and persists for as long as the app is running.
    @StateObject private var promptManager = PromptManager()

    // The `body` property defines the scene for the app, which is the main container of the app's UI.
    var body: some Scene {
        // `WindowGroup` creates the main window for the app. It manages views for different device environments
        // (e.g., iPhone, iPad, Mac).
        WindowGroup {
            // The initial view displayed in the app is `PromptsListView`.
            // The `promptManager` is passed to the view so it can manage the app's list of prompts.
            PromptsListView(manager: promptManager)
                .preferredColorScheme(.dark) // Forces the app to use dark mode, regardless of the system setting.
        }
    }
}


