import SwiftUI
import CoreNFC
import Dispatch

//class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
//    static var  session: NFCNDEFReaderSession?
//    
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        for message in messages {
//            for record in message.records {
//                if let string = String(data: record.payload, encoding: .utf8) {
//                    print(string)
//                }
//            }
//        }
//    }
//    
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        print(error.localizedDescription)
//    }
//    var session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: true)
//    session?.begin()
//}



struct ContentView: View {
    var body: some View {
//        let vc = ViewController()
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
        }
    }
}
