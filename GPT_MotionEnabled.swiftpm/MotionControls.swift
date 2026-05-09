//
// MotionControls.swift
//

import SwiftUI

struct MotionControls: View {
    
    @ObservedObject var viewModel: SceneViewModel
    
    var body: some View {
        
        HStack {
            
            Button {
                
                viewModel.startMotion()
                
            } label: {
                
                Text("Start Motion")
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            .disabled(viewModel.isMotionActive)
            
            Button {
                
                viewModel.stopMotion()
                
            } label: {
                
                Text("Stop Motion")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isMotionActive)
        }
    }
}


