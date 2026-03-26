//  LockOrientation 03/26/2026-4
//  ContentView.swift
//  Project: LockOrientation.swiftpm
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/LockOrientation.swiftpm

import SwiftUI
import UIKit

// Define an enum for orientation options to work with Picker (since UIInterfaceOrientationMask doesn't conform to Hashable)
// Added case for "All But Upside Down" for consistency with onDisappear behavior
enum OrientationOption: String, CaseIterable, Hashable {
    case all = "All"
    case allButUpsideDown = "All But Upside Down"
    case portrait = "Portrait"
    case landscapeLeft = "Landscape Left"
    case landscapeRight = "Landscape Right"
    
    var mask: UIInterfaceOrientationMask {
        switch self {
        case .all: return .all
        case .allButUpsideDown: return .allButUpsideDown
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
    @Environment(\.scenePhase) private var scenePhase  // Leverage scene phases for app lifecycle handling
    
    var body: some View {
        ZStack {
            // Improved: Use semantic color for better theming
            Color(uiColor: .systemBackground)
            NavigationView {
                VStack {
                    // Improved: Make text dynamic to reflect current lock
                    Text(String(format: NSLocalizedString("orientation_locked_to", comment: "Orientation locked message"), selectedOption.rawValue))
                        .padding()
                        .navigationTitle(NSLocalizedString("orientation_lock_demo", comment: "Demo title"))
                        .navigationBarTitleDisplayMode(.inline)
                    
                    Spacer() // Adds flexible space to push the picker to the bottom
                    
                    Picker(NSLocalizedString("select_orientation", comment: "Picker label"), selection: $selectedOption) {
                        ForEach(OrientationOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    // Improved: Added accessibility for better usability
                    .accessibilityLabel(NSLocalizedString("orientation_picker_label", comment: "Accessibility label"))
                    .accessibilityHint(NSLocalizedString("orientation_picker_hint", comment: "Accessibility hint"))
                }
            }
        }
        .onChange(of: selectedOption) { newValue in
            let previousOrientation = UIDevice.current.orientation
            SceneDelegate.orientationLock = newValue.mask
            UIViewController.attemptRotationToDeviceOrientation()
            // Improved: Added error handling/logging for orientation changes
#if DEBUG
            let currentOrientation = UIDevice.current.orientation
            if currentOrientation == previousOrientation {
                print("Warning: Orientation change to \(newValue.rawValue) may have failed. Current orientation: \(currentOrientation.rawValue)")
            } else {
                print("Orientation successfully changed to: \(newValue.rawValue)")
            }
#endif
        }
        .onChange(of: scenePhase) { newPhase in
            // Leverage scene phases: Reset orientation when the app becomes inactive or backgrounds
            if newPhase == .inactive || newPhase == .background {
                selectedOption = .allButUpsideDown
                SceneDelegate.orientationLock = .allButUpsideDown
                
                let previousOrientation = UIDevice.current.orientation
                UIViewController.attemptRotationToDeviceOrientation()
                // Improved: Added error handling/logging
#if DEBUG
                let currentOrientation = UIDevice.current.orientation
                if currentOrientation == previousOrientation {
                    print("Warning: Orientation unlock via scene phase may have failed. Current orientation: \(currentOrientation.rawValue)")
                } else {
                    print("Orientation unlocked successfully via scene phase")
                }
#endif
            }
        }
        .onAppear {
            // Removed: Forced override to respect initial picker state; can be re-added if demo requires it
#if DEBUG
            print("onAppear - Initial orientationLock: \(SceneDelegate.orientationLock)")
            print("UIDevice.current.orientationDidChangeNotification: \(UIDevice.orientationDidChangeNotification)")
#endif
            // If forcing landscape right for demo, uncomment below (but align with selectedOption)
            // selectedOption = .landscapeRight
            // SceneDelegate.orientationLock = .landscapeRight
            // UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
        ContentView()
            .preferredColorScheme(.light)
    }
}
