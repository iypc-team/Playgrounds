//  NFC1 04/12/2026-1
//  ContentView.swift
//  NFC1.swiftpm
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/NFC1.swiftpm

import SwiftUI
import CoreNFC

// Constants for UI spacing and padding
private let verticalSpacing: CGFloat = 40
private let buttonPadding: CGFloat = 16
private let cornerRadius: CGFloat = 10

struct ContentView: View {
    @StateObject var reader = NFCReader()
    
    var body: some View {
        VStack(spacing: verticalSpacing) {
            Text(NSLocalizedString("NFC Result:", comment: "Label for NFC scan result"))
            Text(reader.scanResult)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            scanArea
            clearButton
        }
        .padding()
    }
    
    @ViewBuilder
    private var scanArea: some View {
        if reader.isScanning {
            ProgressView(NSLocalizedString("Scanning...", comment: "Progress indicator during NFC scan"))
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            Button(action: {
                reader.beginScanning()
            }) {
                Text(NSLocalizedString("Start NFC Scan", comment: "Button to initiate NFC scanning"))
                    .padding(buttonPadding)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(cornerRadius)
                // Cannot convert value of type '(CGFloat, Bool) -> some view' to expected argument type 'CGFloat'
            }
            .accessibilityLabel(NSLocalizedString("Start NFC Scan", comment: "Accessibility label for scan button"))
            .accessibilityHint(NSLocalizedString("Tap to begin scanning for NFC tags", comment: "Accessibility hint for scan button"))
            .disabled(reader.isScanning)
        }
    }
    
    @ViewBuilder
    private var clearButton: some View {
        if !reader.scanResult.isEmpty && !reader.isScanning {
            Button(action: {
                reader.clearResult()
            }) {
                Text(NSLocalizedString("Clear", comment: "Button to clear scan result"))
                    .padding(buttonPadding)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(cornerRadius)
            }
            .accessibilityLabel(NSLocalizedString("Clear Result", comment: "Accessibility label for clear button"))
            .accessibilityHint(NSLocalizedString("Tap to clear the NFC scan result", comment: "Accessibility hint for clear button"))
        }
    }
}
