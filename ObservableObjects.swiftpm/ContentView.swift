//  ObservableObjects 01/25/2026-1
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/ObservableObjects.swiftpm
// 
//. 18
import SwiftUI

class UserProgress: ObservableObject {
    @Published var score = 0
    
    let fontSize: CGFloat = CGFloat(24)
}

struct InnerView: View {
    @ObservedObject var progress: UserProgress
    
    var body: some View {
        Button("Increase Score") {
            progress.score += 1
        }
        .font(.system(size: progress.fontSize, weight: .semibold, design: .default))
        .padding()
        Button("Decrease Score") {
            progress.score -= 1
        }
        .font(.system(size: progress.fontSize, weight: .semibold, design: .default))
    }
}

struct ContentView: View {
    @StateObject var progress = UserProgress()
    
    var body: some View {
        VStack {
            Text("Your score is \(progress.score)")
                .font(.system(size: progress.fontSize, weight: .semibold, design: .default))
            InnerView(progress: progress)
        }
    }
}



struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

