// Lumo Airplane  11/28/2025-initial commit
// 

import SwiftUI

// SwiftUI view (iOS 16)
struct AirplaneView: View {
    @StateObject var vm = AirplaneViewModel()
    @State var model: AirplaneModel?
    
    var body: some View {
        ZStack {
            if let m = model {
                ARViewContainer(airplaneEntity: m.entity) { _ in
                    // The closure pulls the latest quaternion from the VM.
                }
                .ignoresSafeArea()
            } else {
                ProgressView()
            }
            // optional UI controls …
        }
        .task {
            model = try? await AirplaneModel.load()
        }
    }
}
