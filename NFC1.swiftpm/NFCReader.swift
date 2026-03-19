// NFCReader.swift
//  

import SwiftUI
import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var scanResult: String = ""
    //  Type 'NFCReader' does not conform to protocol 'NFCTagReaderSessionDelegate'. Show fully updated code snippet
    var session: NFCTagReaderSession?
    
    func beginScanning() {
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your iPhone near the NFC tag."
        session?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.scanResult = "Session invalidated: \(error.localizedDescription)"
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tag detected. Please present only 1 tag."
            session.invalidate()
            return
        }
        
        guard let tag = tags.first else { return }
        session.connect(to: tag) { (error: Error?) in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            
            switch tag {
            case .miFare(let mifareTag):
                let identifier = mifareTag.identifier.map { String(format: "%.2hhx", $0) }.joined()
                session.alertMessage = "Tag detected (MiFare): \(identifier)"
                DispatchQueue.main.async {
                    self.scanResult = "Tag ID: \(identifier)"
                }
                session.invalidate()
                // Handle other tag types (.iso7816, .iso15693, .feliCa) if needed
            default:
                session.invalidate(errorMessage: "Unsupported tag type")
            }
        }
    }
}
