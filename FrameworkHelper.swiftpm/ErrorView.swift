// ErrorView.swift
// 

import SwiftUI

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Preview

#Preview {
    ErrorView(error: "Failed to load data. Please check your connection.") {
        print("Retry tapped")
    }
}
