//  FrameworkRow.swift
//  

import SwiftUI

struct FrameworkRow: View {
    let framework: Framework
    
    var body: some View {
        HStack {
            Text(framework.name)
                .font(.body)
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(framework.name)
    }
}
