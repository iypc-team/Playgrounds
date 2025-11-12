//

import Foundation

struct AirplaneModel {
    let filename: String
    let fileExtension: String = "usdz"
    
    func getModelURL() -> URL? {
        return Bundle.main.url(forResource: filename, withExtension: fileExtension)
    }
}

