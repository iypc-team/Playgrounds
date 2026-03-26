//  LockOrientation 03/26/2026-6
//  ContentView.swift
//  Project: LockOrientation.swiftpm
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/LockOrientation.swiftpm

import SwiftUI
import UIKit

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

@MainActor
struct ContentView: View {
    @EnvironmentObject private var orientationManager: OrientationManager
    @State private var selectedOption: OrientationOption = .all
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            NavigationView {
                VStack {
                    Text(
                        String(format: NSLocalizedString("orientation_locked_to",
                                                         comment: "Orientation locked message"),
                               selectedOption.rawValue)
                    )
                    .padding()
                    .navigationTitle(NSLocalizedString("orientation_lock_demo", comment: "Demo title"))
                    .navigationBarTitleDisplayMode(.inline)
                    
                    Spacer()
                    
                    Picker(NSLocalizedString("select_orientation", comment: "Picker label"),
                           selection: $selectedOption) {
                        ForEach(OrientationOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                           .pickerStyle(.menu)
                           .padding()
                           .accessibilityLabel(NSLocalizedString("orientation_picker_label", comment: "Accessibility label"))
                           .accessibilityHint(NSLocalizedString("orientation_picker_hint", comment: "Accessibility hint"))
                }
            }
        }
        .onChange(of: selectedOption) { newValue in
            let previous = UIDevice.current.orientation
            orientationManager.set(newValue.mask)
#if DEBUG
            let current = UIDevice.current.orientation
            if current == previous {
                print("Warning: orientation change to \(newValue.rawValue) may have failed. Current: \(current.rawValue)")
            } else {
                print("Orientation changed to: \(newValue.rawValue)")
            }
#endif
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive || newPhase == .background {
                selectedOption = .allButUpsideDown
                let previous = UIDevice.current.orientation
                orientationManager.set(selectedOption.mask)
#if DEBUG
                let current = UIDevice.current.orientation
                if current == previous {
                    print("Warning: scene-phase unlock may have failed. Current: \(current.rawValue)")
                } else {
                    print("Orientation unlocked via scene phase")
                }
#endif
            }
        }
        .onAppear {
#if DEBUG
            print("onAppear - initial orientationLock: \(orientationManager.mask)")
            print("UIDevice.current.orientationDidChangeNotification: \(UIDevice.orientationDidChangeNotification)")
#endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OrientationManager.shared)
            .preferredColorScheme(.dark)
        ContentView()
            .environmentObject(OrientationManager.shared)
            .preferredColorScheme(.light)
    }
}
