import SwiftUI

@MainActor
final class MVVMBootcampViewModel: ObservableObject  {
    var managerClass = ManagerClass()
    var managerActor = ManagerActor()
    
    @Published private(set) var pressCount = 0
    @Published private(set) var myData: String = "Starting text"
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks()  {
        print("func cancelTasks() ")
        for task in tasks {
            print("\(task)")
        } 
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    func onCallToActionButton()  {
        self.pressCount += 1
        print("\(self.pressCount) Click Here pressed")
        let task = Task {
            do {
                myData = try await managerClass.getData()
            } catch { print(error.localizedDescription) }
        }
        tasks.append(task)
    }
}
