// FrameworkRow.swift

import SwiftUI

struct FrameworkRow: View {
    let framework: Framework
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(framework.displayName)
                .font(.headline)
            
            Text(framework.name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
