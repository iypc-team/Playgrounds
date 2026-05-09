//
// AppLogger.swift
//

import os

enum AppLogger {
    
    static let scene = Logger(
        subsystem: "DF22_MotionEnabled",
        category: "Scene"
    )
    
    static let motion = Logger(
        subsystem: "DF22_MotionEnabled",
        category: "Motion"
    )
}

