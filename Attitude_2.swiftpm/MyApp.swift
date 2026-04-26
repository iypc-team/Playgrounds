import SwiftUI
import UIKit

struct LandscapeHostingController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LandscapeRightViewController {
        let controller = LandscapeRightViewController()
        let hostingController = UIHostingController(rootView: ContentView().preferredColorScheme(.dark))
        hostingController.view.frame = controller.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.addChild(hostingController)
        controller.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: controller)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: LandscapeRightViewController, context: Context) {
        // No updates needed
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            LandscapeHostingController()
                .ignoresSafeArea()  // Ensures full-screen coverage
        }
    }
}
