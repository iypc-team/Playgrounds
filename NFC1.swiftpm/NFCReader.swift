// NFCReader.swift
// Handles NFC tag scanning and result publishing.

import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var scanResult: String = ""
    @Published var isScanning: Bool = false
    private var session: NFCNDEFReaderSession?
    
    /// Initiates NFC scanning if available on the device.
    /// - Note: Invalidates after first successful read.
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            scanResult = NSLocalizedString("NFC reading is not available on this device.", comment: "Error message for unsupported device")
            print("scanResult: \(scanResult)")
            return
        }
        isScanning = true
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = NSLocalizedString("Hold your iPhone near an NFC tag.", comment: "Alert message during scanning")
        session?.begin()
    }
    
    /// Clears the current scan result.
    func clearResult() {
        scanResult = ""
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("Reader session did become active.")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Reader session did invalidate with error: \(error.localizedDescription)")
        isScanning = false
        if scanResult.isEmpty {
            scanResult = NSLocalizedString("Scanning failed. Try again.", comment: "Generic error message for scan failure")
        }
        self.session = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let message = messages.first, let record = message.records.first else {
            scanResult = NSLocalizedString("No NDEF data found.", comment: "Message when no data is detected")
            session.invalidate()
            isScanning = false
            return
        }
        
        // Parse payload based on record type
        var payloadString: String
        switch record.typeNameFormat {
        case .nfcWellKnown:
            if record.type == Data([0x55]) { // URI record
                payloadString = parseURIPayload(record.payload)
            } else if record.type == Data([0x54]) { // Text record
                payloadString = parseTextPayload(record.payload)
            } else {
                payloadString = String(data: record.payload, encoding: .utf8) ?? record.payload.debugDescription
            }
        default:
            payloadString = String(data: record.payload, encoding: .utf8) ?? record.payload.debugDescription
        }
        
        scanResult = String(format: NSLocalizedString("NFC Tag Detected: %@", comment: "Success message with payload"), payloadString)
        session.invalidate()
        isScanning = false
    }
    
    /// Parses a URI payload (e.g., for well-known URI records).
    private func parseURIPayload(_ payload: Data) -> String {
        guard payload.count > 1 else { return "Invalid URI" }
        let prefixIndex = Int(payload[0])
        let uriPrefixes = [
            "http://www.", "https://www.", "http://", "https://", "tel:", "mailto:",
            "ftp://anonymous:anonymous@", "ftp://ftp.", "ftps://", "sftp://", "smb://", "nfs://",
            "ftp://", "dav://", "news:", "telnet://", "imap:", "rtsp://", "urn:", "pop:", "sip:",
            "sips:", "tftp:", "btspp://", "btl2cap://", "btgoep://", "tcpobex://", "irdaobex://",
            "file://", "urn:epc:id:", "urn:epc:tag:", "urn:epc:pat:", "urn:epc:raw:", "urn:epc:",
            "urn:nfc:"
        ]
        let prefix = (prefixIndex < uriPrefixes.count) ? uriPrefixes[prefixIndex] : ""
        let uriData = payload[1...]
        return prefix + (String(data: uriData, encoding: .utf8) ?? "")
    }
    
    /// Parses a text payload (e.g., for well-known text records).
    private func parseTextPayload(_ payload: Data) -> String {
        guard payload.count > 1 else { return "Invalid Text" }
        let statusByte = payload[0]
        let utf16 = (statusByte & 0x80) != 0
        let encoding: String.Encoding = utf16 ? .utf16 : .utf8
        let languageLength = Int(statusByte & 0x3F)
        let textStart = 1 + languageLength
        guard textStart < payload.count else { return "Invalid Text" }
        let textData = payload[textStart...]
        return String(data: textData, encoding: encoding) ?? "Unreadable Text"
    }
}
