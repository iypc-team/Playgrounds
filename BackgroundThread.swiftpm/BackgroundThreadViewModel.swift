//  print
import SwiftUI


class BackgroundThreadViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    @Published var newLine:String = "\n"
    
    func fetchData() {
        DispatchQueue(label: "BackgroundThread", 
                      qos: .background, 
                      attributes: .concurrent, 
                      autoreleaseFrequency: .inherit, 
                      target: .global(qos: .background)).async { [weak self] in
            let newData = self?.createData()
            DispatchQueue.main.async {
                self?.dataArray = newData!
            }
            
        }
        
//        DispatchQueue.global(qos: .background).async { [self] in
//            
//            let newData = self.createData()
//            self.dataArray = newData
//            print("\(Thread.current)")
//        }
    }
    
    private func createData() -> [String] {
        var data: [String] = []
        let infinity: Int = 1_000_000
        for x in 0...infinity {
            data.append("\(x)")
//            print("\(Thread.current)")
            print("\(x)")
        }
        return data
    }
    
    func printInfo() {
        print("dataArray: \(dataArray)")
    }
}
