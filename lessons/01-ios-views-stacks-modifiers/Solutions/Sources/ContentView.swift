import SwiftUI

// Reference solution for lesson 01 (overlays Sources/ContentView.swift in ./verify.sh; not compiled into the app).

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Ex 1: header row = avatar + name block + pushed-right "button"
            HStack(spacing: 12) {
                Circle()
                    .fill(.blue)
                    .frame(width: 56, height: 56)
                    // Ex 3: overlay is drawn on top of, and sized by, the view it modifies
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(.green)
                            .frame(width: 14, height: 14)
                            .overlay { Circle().stroke(.white, lineWidth: 2) }
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ada Lovelace")
                        .font(.headline)                    // Ex 4
                    Text("@ada · London")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()                                    // ≈ flex: 1 filler

                Text("Follow")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.blue, in: .capsule)
                    .foregroundStyle(.white)
            }

            Text("Wrote the first published algorithm intended for a machine.")
                .font(.body)
                .lineLimit(2)
        }
        // Ex 2: padding BEFORE background → the background includes the padding.
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        // Outer padding AFTER the background → space outside the card.
        .padding(20)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ContentView()
}
