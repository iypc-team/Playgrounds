// NFCReader.swift
//  

import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var scanResult: String = ""
    private var session: NFCNDEFReaderSession?
    
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            scanResult = "NFC reading is not available on this device."
            print("scanResult: \(scanResult)")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near an NFC tag."
        session?.begin()
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("Reader session did become active.")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Reader session did invalidate with error: \(error.localizedDescription)")
        self.session = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let message = messages.first, let record = message.records.first else {
            scanResult = "No NDEF data found."
            session.invalidate()
            return
        }
        
        // Convert payload to string (assuming UTF-8)
        if let payloadString = String(data: record.payload, encoding: .utf8) {
            scanResult = "NFC Tag Detected: \(payloadString)"
        } else {
            scanResult = "NFC Tag Detected: \(record.payload.debugDescription)"
        }
        session.invalidate()
    }
}
