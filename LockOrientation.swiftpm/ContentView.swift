//  LockOrientation 03/25/2026-1
//  ContentView.swift
//  Project: LockOrientation.swiftpm
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/LockOrientation.swiftpm

import SwiftUI
import UIKit

// Define an enum for orientation options to work with Picker (since UIInterfaceOrientationMask doesn't conform to Hashable)
enum OrientationOption: String, CaseIterable, Hashable {
    case all = "All"
    case portrait = "Portrait"
    case landscapeLeft = "Landscape Left"
    case landscapeRight = "Landscape Right"
    
    var mask: UIInterfaceOrientationMask {
        switch self {
        case .all: return .all
        case .portrait: return .portrait
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        }
    }
}

// UIDevice.orientationDidChangeNotification
@MainActor
struct ContentView: View {
    @State private var selectedOption: OrientationOption = .all
    
    var body: some View {
        ZStack {
            Color.blue
            NavigationView {
                VStack {
                    Text("Orientation Locked to Landscape")
                        .padding()
                        .navigationTitle("Orientation Lock Demo")
                        .navigationBarTitleDisplayMode(.inline)
                    
                    Spacer() // Adds flexible space to push the picker to the bottom
                    
                    Picker("Select Orientation", selection: $selectedOption) {
                        ForEach(OrientationOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
            }
        }
        .onChange(of: selectedOption) { newValue in
            AppDelegate.orientationLock = newValue.mask
            UIViewController.attemptRotationToDeviceOrientation()
            print("Orientation changed to: \(newValue.rawValue)")
        }
        .onAppear {
            // Forcing the rotation to landscape right by default
            selectedOption = .landscapeRight
            AppDelegate.orientationLock = .landscapeRight
            
            print("onAppear")
            print("orientationLock: \(AppDelegate.orientationLock)")
            print("UIDevice.current: \(UIDevice.orientationDidChangeNotification)\n")
            
            UIViewController.attemptRotationToDeviceOrientation()
        }
        .onDisappear {
            // Unlocking the rotation when leaving the view
            selectedOption = .all
            AppDelegate.orientationLock = .allButUpsideDown
            
            print("onDisappear")
            print("orientationLock: \(AppDelegate.orientationLock)")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}


