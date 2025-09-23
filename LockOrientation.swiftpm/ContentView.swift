import SwiftUI
import UIKit

//UIDevice.orientationDidChangeNotification
@MainActor
struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue
            NavigationView {
                Text("Hello, world!  Kiss my ass.")
                    .padding()
                    .navigationTitle("Turkey Gizzards")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }.onAppear {
            // Forcing the rotation to portrait
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.landscapeRight
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                
                print("onAppear")
                print("orientationLock: \(AppDelegate.orientationLock)")
                print("UIDevice.current: \(UIDevice.orientationDidChangeNotification)\n")
            }
        }.onDisappear {
            // Unlocking the rotation when leaving the view
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
                
                print("onDisappear")
                print("orientationLock: \(AppDelegate.orientationLock)")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
