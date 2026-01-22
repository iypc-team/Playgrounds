//  Polyhedron Viewer  01/21/2026-2
//  
//  PolyhedronViewer.swift
//  Created by Code GPT 🧠 on 01/21/2026.
//  Copyright © 2018 IYPC Software. All rights reserved.
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/Polyhedron%20Viewer.swiftpm
//
//  

import SwiftUI
import SceneKit
import UIKit

// MARK: - SwiftUI SceneKit Bridge
struct SceneKitView: UIViewControllerRepresentable {
    @Binding var currentSolid: PlatonicSolid
    @Binding var wireframeMode: Bool
    @Binding var rotationEnabled: Bool
    
    func makeUIViewController(context: Context) -> GameViewController {
        let controller = GameViewController()
        controller.loadPolyhedron(type: currentSolid, wireframe: wireframeMode)
        controller.setRotation(enabled: rotationEnabled)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        uiViewController.loadPolyhedron(type: currentSolid, wireframe: wireframeMode)
        uiViewController.setRotation(enabled: rotationEnabled)
    }
}

// MARK: - Main SwiftUI Viewer
struct PolyhedronViewer: View {
    @State private var currentSolid: PlatonicSolid = .dodecahedron
    @State private var wireframeMode: Bool = false
    @State private var rotationEnabled: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // SceneKit content
            SceneKitView(currentSolid: $currentSolid,
                         wireframeMode: $wireframeMode,
                         rotationEnabled: $rotationEnabled)
            .edgesIgnoringSafeArea(.all)
            
            // Control overlay
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Tetrahedron") { currentSolid = .tetrahedron }
                        .buttonStyle(PolyButtonStyle(selected: currentSolid == .tetrahedron))
                    Button("Tetrahedron") { currentSolid = .cube }
                        .buttonStyle(PolyButtonStyle(selected: currentSolid == .cube))
                    Button("Octahedron") { currentSolid = .octahedron }
                        .buttonStyle(PolyButtonStyle(selected: currentSolid == .octahedron))
                    Button("Dodecahedron") { currentSolid = .dodecahedron }
                        .buttonStyle(PolyButtonStyle(selected: currentSolid == .dodecahedron))
                    Button("Icosahedron") { currentSolid = .icosahedron }
                        .buttonStyle(PolyButtonStyle(selected: currentSolid == .icosahedron))
                }
                
                Toggle("Wireframe Mode", isOn: $wireframeMode)
                    .toggleStyle(SwitchToggleStyle(tint: .cyan))
                    .padding(.horizontal, 40)
                    .foregroundColor(.white)
                
                Button(rotationEnabled ? "⏸ Stop Rotation" : "▶️ Start Rotation") {
                    rotationEnabled.toggle()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 20)
                .background(Color.cyan.opacity(0.6))
                .cornerRadius(10)
            }
            .padding(.bottom, 20)
            .background(Color.black.opacity(0.4).blur(radius: 5))
            .cornerRadius(12)
        }
    }
}

// MARK: - Button Styling
struct PolyButtonStyle: ButtonStyle {
    var selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(selected ? Color.clear : Color.gray.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Preview
struct PolyhedronViewer_Previews: PreviewProvider {
    static var previews: some View {
        PolyhedronViewer()
            .preferredColorScheme(.dark)
    }
}

