//  MotionControls.swift
// 

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
