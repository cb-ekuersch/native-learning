import SwiftUI

@main
struct __APP__App: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Lesson __NUM__ · __TITLE__")
            .padding()
    }
}

#Preview { ContentView() }
