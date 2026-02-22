//  iCloudDrive 02/22/2026-4
//  ContentView.swift
//  Repo:  https://github.com/iypc-team/Playgrounds/tree/main/iCloudDrive.swiftpm

//  ContentView.swift

import SwiftUI

struct ContentView: View {
    // Observing the GreetingViewModel
    @StateObject private var viewModel = GreetingViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            // Displaying the greeting from the ViewModel
            Text(viewModel.greeting)
                .font(.title)
                .padding()
        }
        .onAppear {
            // Load the greeting when the view appears
            viewModel.loadGreeting()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
