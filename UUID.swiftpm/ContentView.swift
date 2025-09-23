// 
import SwiftUI

struct Idd {
    var uuid: String = NSUUID().uuidString
    var uuidArray: [String] = []
    public var uuidSet: Set<String> = []
    
    func getNewUUID() -> String {
        let thisUUID = NSUUID().uuidString
        return thisUUID
    }
    
    mutating func appendElement(element: String) {
        print(element)
        uuidSet.update(with: element)
        uuidArray.append(element)
    }
}
struct createSet {
    public static var uuidSet: Set<String> = []
}

class Id {
    public var uuid: String = NSUUID().uuidString
    public var uuidSet: Set<String> = []
    
    func getNewUUID() -> String {
        let thisUUID = NSUUID().uuidString
        uuidSet.update(with: thisUUID)
//        print("\nuuid: : \(thisUUID)")
        for item in uuidSet {
            print("\(item)")
        }
        print(uuidSet.count)
        return thisUUID
    }
}


struct ContentView: View {
    let id = Id()
    var uuid: String = NSUUID().uuidString
    var body: some View {
        Text("UUID: \(id.getNewUUID())")
            .font(.system(size: 16, weight: .black, design: .serif))
            .multilineTextAlignment(.center)
            .bold()
//        Text("UUID: \(id.getNewUUID())")
//            .font(.system(size: 16, weight: .black, design: .serif))
//            .multilineTextAlignment(.center)
//            .bold()
    }
}

//let man = Man("Victor", "Titov")
//print("firstName is \(man.firstName)")
    
struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
