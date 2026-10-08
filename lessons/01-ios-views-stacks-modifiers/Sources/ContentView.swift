import SwiftUI

// Lesson 01 — Views, stacks and modifiers.
// Goal: turn this unstyled pile of views into the profile card sketched in README.md ("Done when").
//
// Every TODO is tagged with its exercise number. Rebuild with ./run.sh, or keep the
// Xcode Preview canvas open (⌥⌘↩) to see changes live as you type.

struct ContentView: View {
    var body: some View {
        // TODO (Ex 1): arrange these with VStack / HStack / Spacer.
        // The explicit VStack below currently puts every piece in one vertical column.
        VStack {
            Circle()                       // the "avatar"
                .fill(.blue)
                .frame(width: 56, height: 56)
                // TODO (Ex 3): add an online-status dot with .overlay(alignment: .bottomTrailing).

            Text("Ada Lovelace")
            Text("@ada · London")
            Text("Wrote the first published algorithm intended for a machine.")

            Text("Follow")                 // pretend button — real buttons come in a later lesson
        }
        // TODO (Ex 2): card styling with modifiers (padding, background, clipShape) — order matters!
        // TODO (Ex 4): text styling (font, foregroundStyle, lineLimit)
    }
}

#Preview {
    ContentView()
}
