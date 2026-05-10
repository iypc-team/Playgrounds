//
// AppLogger.swift
//

import os

enum AppLogger {
    
    static let scene = Logger(subsystem: "com.iypc.DF22_MotionEnabled", category: "Scene")
    static let motion = Logger(subsystem: "com.iypc.DF22_MotionEnabled", category: "Motion")
    static let ui = Logger(subsystem: "com.iypc.DF22_MotionEnabled", category: "UI")
    
    // Convenience methods (optional but nice)
    static func debug(_ message: String, category: Logger? = nil) {
        (category ?? scene).debug("\(message)")
    }
}
