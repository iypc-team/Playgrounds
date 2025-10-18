// MotionViewModel
//

import Foundation

final class MotionViewModel: ObservableObject  {
    @Published var isAnimating: Bool = false
    
    func tappedAnimation()  {
        isAnimating.toggle()
    }
    func tappedToggleMotion()  {
        
    }
}



