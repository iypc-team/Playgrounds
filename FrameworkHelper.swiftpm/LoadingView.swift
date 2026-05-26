// LoadingView.swift
// 

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    LoadingView()
}

