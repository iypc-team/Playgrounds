import SwiftUI

enum AnySound {
    case beat(BeatSounds)
    case bass(BassSounds)
    case melodic(MelodicSounds)
    case ambient(AmbientSounds)
    case soundfx(SoundFXSounds)
}

enum BeatSounds: Sound {
    case CosmicBeat,
    DiscoBeat1,
    DiscoBeat6,
    FeverBeat,
    GlowBeat,
    GoTimeBeat2,
    HotBeat1,
    SolarisBeat2
}

enum BassSounds: Sound {
    case CosmicBass,
         DreamsBass1,
         DreamsBass4,
         LesInfernoBass,
         ParisNightsBass,
         PrismaticaBass6,
         PrismaticaBass7,
         SaintTropezBass,
         SolarisBass3
}

enum MelodicSounds: Sound {
    case DreamsChords3,
         DreamsChords5,
         DreamsChords6,
         DreamsLead1,
         GlowChords,
         ParisArpeggio,
         PrismaticaChords2,
         PrismaticaChords6,
         SensationArpeggio,
         SolarisChords2
}

enum AmbientSounds: Sound {
    case DiscoSynth1,
         DiscoSynth2,
         GlitterSynth,
         FunkSynth1,
         DreamsSynth1,
         DreamsSynth4,
         PrismaticaSynth2,
         SolarisString,
         SolarisSynth1,
         SolarisSynth2
}

enum SoundFXSounds: Sound {
    case BotTalkFX3,
         BotTalkFX4,
         FirstGearFX,
         HornBassFX,
         KazooFX3,
         KazooFX4,
         PlanetariumFX3,
         PlanetariumFX6,
         SweeperFX1,
         TromboneFX1,
         VoxFX1
}

enum Pitch: Double {
    case D_b = 100
    case D = 200
    case E_b = 300
    case E = 400
    case F = 500
    case G_b = 600
    case G = 700
    case A_b = 800
    case A = 900
    case B_b = 1000
    case B = 1100
    case C = 1200
}
