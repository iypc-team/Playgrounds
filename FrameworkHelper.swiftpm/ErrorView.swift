// ErrorView.swift

import SwiftUI

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        ZStack {
            // Dims the content behind the error card.
            Color(.systemBackground)
                .opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // ✅ .fill variant is more visually prominent than the outline version.
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 52))
                // ✅ foregroundStyle replaces deprecated foregroundColor.
                    .foregroundStyle(.red)
                
                Text("Something went wrong")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(error)
                    .font(.body)
                // ✅ foregroundStyle replaces deprecated foregroundColor.
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button(action: retryAction) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview {
    ErrorView(error: "Failed to load data. Please check your connection.") {
        print("Retry tapped")
    }
}
