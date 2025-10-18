// MotionView
//  

import SwiftUI
import CoreMotion
import Foundation

struct ContentView: View  {
    @State private var shapes: [AnyView] = []
    @StateObject private var viewModel = MotionViewModel()
    private var colors: [Color] = [.cyan, .purple, .orange, .green, .yellow, .red, .blue]
    
    var body: some View  {
//        print("  colors.count: \(colors.count)")
        ZStack  {
            Rectangle().fill(Color.clear)
            contentShapes
            ctas
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: {
            addShape()
        })
    }
    
    private var contentShapes: some View {
        ForEach(shapes.indices, id: \.self) { index in
            shapes[index]
        }
    }
    
    private var ctas: some View  {
        VStack {
            Spacer()
            Button(action: {}) {
                Text("Animate")
            }
        }
        padding(.bottom)
        return body
    }
    
    private func addShape()  {
        shapes.append(AnyView(
            Circle()
                .fill(colors.randomElement() ?? .cardinalRed)
                .frame(width: 60, height: 60)
                .offset(randomOffsetPosition())
            ))
    }
    private func randomOffset() -> CGSize  {
        let xOffset = CGFloat.random(in: -40...40)
        let yOffset = CGFloat.random(in: -200...0)
        return CGSize(width: xOffset, height: yOffset)
    }
    
    private func randomOffsetPosition() -> CGSize  {
        let xOffset = CGFloat.random(in: -100...100)
        let yOffset = CGFloat.random(in: -100...100)
        return CGSize(width: xOffset, height: yOffset)
    }
}

struct ContentView_Previews: PreviewProvider  {
    static var previews: some View  {
        ContentView()
            .preferredColorScheme(.dark)
    }
}




