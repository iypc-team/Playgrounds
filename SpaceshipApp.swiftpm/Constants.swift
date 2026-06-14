// Constants.swift
// Centralized constants for iOS 16.6 compatibility

import SwiftUI
import RealityKit

enum Constants {
    // MARK: - UI Dimensions
    static let buttonPadding: CGFloat = 10
    static let fontSize: CGFloat = 18
    static let cornerRadius: CGFloat = 8
    static let scaleFactor: CGFloat = 1.0
    
    // MARK: - 3D Interaction
    static let dragSensitivity: Double = 0.006
    static let autoRotationSpeedDegreesPerFrame: Double = 0.8
    static let maxPitchDegrees: Double = 80
    
    // MARK: - RealityKit Scene Setup
    static let cameraDistance: Float = 22.0
    static let directionalLightIntensity: Float = 3000
    static let skyboxIntensityExponent: Float = 1.15
    static let lightTiltAngleRadians: Float = -.pi / 3
}
