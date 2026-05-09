//
// ShipType.swift
//

import Foundation

// 1. Type-safe enum for Ship selections — kept in sync with scene assets.
enum ShipType: String, CaseIterable, Identifiable {
    case fighter     = "fighter"
    case newFighter  = "newFighter"
    case fighterPBR  = "fighterPBR"
    case smoothShip  = "smooth_ship"
    case airplane    = "airplane"
    case yUpFighter  = "Y-Up-fighter.scn"
    
    var id: String { rawValue }
    
    var sceneFileName: String {
        rawValue.hasSuffix(".scn") ? rawValue : "\(rawValue).scn"
    }
    
    var rootNodeName: String {
        switch self {
        case .fighter:
            return "fighter"
            
        case .newFighter:
            return "fighter"
            
        case .fighterPBR:
            return "fighter"
            
        case .smoothShip:
            return "enemy"
            
        case .airplane:
            return "ship"
            
        case .yUpFighter:
            return "fighter"
        }
    }
    
    var displayName: String {
        switch self {
        case .fighter:
            return "Fighter"
            
        case .newFighter:
            return "New Fighter"
            
        case .fighterPBR:
            return "Fighter PBR"
            
        case .smoothShip:
            return "Smooth Ship"
            
        case .airplane:
            return "Airplane"
            
        case .yUpFighter:
            return "Y-Up Fighter"
        }
    }
}

