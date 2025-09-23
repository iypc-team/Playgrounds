// NFCReader.swift
import SwiftUI
import CoreNFC

class NFCReader: NSObject, NFCReaderDelegate, NFCTagReaderSessionDelegate {
    @State private var tagData: Data?
    
    init(
        delegate: any NFCNDEFReaderSessionDelegate,
        queue: dispatch_queue_t?,
        invalidateAfterFirstRead: Bool
    ) {
        print("delegate\n", delegate)
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("readerSessionDidBecomeActive")
        return
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("didDetectNDEF messages\n", messages)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        print("tags\n", tags)
    }
    
    func startReading() {
        let reader = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        reader?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        @State var identifier = tagData?.debugDescription
        if let tag = tags.first {
            session.connect(to: tag) { (error) in
                if let error = error {
                    print("Error connecting to tag: \(error)")
                } else {
//                    self.tagData = tag.identifier
                    print("tags\n", tags)
                }
            }
        }
    }
}
