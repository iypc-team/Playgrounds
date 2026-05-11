//  MotionControls.swift
// Fix #4 — Removed tight @ObservedObject coupling to SceneViewModel.
// MotionControls now receives only the data and actions it needs,
// making it reusable, testable, and isolated from ViewModel changes.

import SwiftUI

struct MotionControls: View {
    
    let isMotionActive: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        
        HStack {
            
            Button {
                
                onStart()
                
            } label: {
                
                Text("Start Motion")
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            .disabled(isMotionActive)
            
            Button {
                
                onStop()
                
            } label: {
                
                Text("Stop Motion")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            .disabled(!isMotionActive)
        }
    }
}
