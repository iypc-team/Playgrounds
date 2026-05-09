//
// OrientationPanel.swift
//

import SwiftUI

struct OrientationPanel: View {
    
    let orientation: OrientationState
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Text("Device Orientation")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                
                IndicatorView(
                    title: "Roll",
                    value: orientation.roll,
                    unit: "°",
                    color: .orange
                )
                
                IndicatorView(
                    title: "Pitch",
                    value: orientation.pitch,
                    unit: "°",
                    color: .cyan
                )
                
                IndicatorView(
                    title: "Yaw",
                    value: orientation.yaw,
                    unit: "°",
                    color: .purple
                )
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct IndicatorView: View {
    
    let title: String
    
    let value: Double
    
    let unit: String
    
    let color: Color
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(
                "\(value * 180 / .pi, specifier: "%.1f")\(unit)"
            )
            .font(.title2.monospacedDigit().bold())
            .foregroundColor(color)
        }
    }
}

