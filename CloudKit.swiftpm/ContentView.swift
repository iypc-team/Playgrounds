import SwiftUI
import CloudKit

class CloudKitUserViewModel: ObservableObject {
    @Published var isSignedInToICloud: Bool = false
    @Published var error: String = ""
    
    init() {
        getiCloudStatus()
    }
    
    private func getiCloudStatus() {
        CKContainer.default().accountStatus { returnedStatus, returnedError in 
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self.isSignedInToICloud = true
                case .couldNotDetermine:
                    self.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self.error = CloudKitError.iCloudAccountRestricted.rawValue
                case .noAccount:
                    self.error = CloudKitError.iCloudAccountNotFound.rawValue
//                case .temporarilyUnavailable:
//                    self?.error = CloudKitError
//                    break. //  find enum response
                default:
                    self.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
            }
        }
    }
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountUnknown
        case iCloudAccountRestricted
    }
}

struct CloudKitUser: View {
    @StateObject private var vm = CloudKitUserViewModel()
    var body: some View {
        VStack {
            Text("User signed in: \(vm.isSignedInToICloud.description)")
            Text("\(vm.error)")
        }
    }
}



struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        CloudKitUser()
            .preferredColorScheme(.dark)
    }
}
