// LoadingView.swift

import SwiftUI

struct LoadingView: View {
    // ✅ Accepts a custom message so callers can provide context (e.g. "Loading Core Motion…")
    var message: String = "Loading..."
    
    var body: some View {
        ZStack {
            // Dims the content behind the spinner.
            Color(.systemBackground)
                .opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text(message)
                    .font(.headline)
                // ✅ foregroundStyle replaces deprecated foregroundColor.
                    .foregroundStyle(.secondary)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview {
    LoadingView()
}

#Preview("Custom message") {
    LoadingView(message: "Loading frameworks...")
}
