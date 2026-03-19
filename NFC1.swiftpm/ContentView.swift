//  NFC1 03/19/2026-5
//  ContentView.swift
//  NFC1.swiftpm
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/NFC1.swiftpm

import SwiftUI
import CoreNFC

struct ContentView: View {
    @StateObject var reader = NFCReader()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("NFC Result:")
            Text(reader.scanResult)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button(action: {
                reader.beginScanning()
            }) {
                Text("Start NFC Scan")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
