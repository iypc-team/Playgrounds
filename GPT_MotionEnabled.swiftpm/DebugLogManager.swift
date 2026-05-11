// DebugLogManager.swift
// 

import SwiftUI

@MainActor
final class DebugLogManager: ObservableObject {
    static let shared = DebugLogManager()
    
    @Published var messages: [String] = []
    private let maxMessages = 30
    
    func log(_ message: String) {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        let entry = "[\(timestamp)] \(message)"
        
        DispatchQueue.main.async {
            self.messages.append(entry)
            if self.messages.count > self.maxMessages {
                self.messages.removeFirst()
            }
        }
    }
    
    func clear() {
        messages.removeAll()
    }
}

struct DebugLogView: View {
    @StateObject private var logManager = DebugLogManager.shared
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("📟 Debug Logs")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Text("\(logManager.messages.count)")
                    .font(.caption)
                
                Button("Clear") { logManager.clear() }
                    .font(.caption)
                
                Button(isExpanded ? "Hide" : "Show") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
            }
            .padding(8)
            .background(.ultraThinMaterial)
            
            if isExpanded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(logManager.messages, id: \.self) { msg in
                            Text(msg)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(8)
                }
                .frame(maxHeight: 260)
                .background(.black.opacity(0.85))
            }
        }
        .cornerRadius(12)
        .padding()
    }
}
