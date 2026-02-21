import SwiftUI

struct GlassTheme: Identifiable {
    let id = UUID()
    let colorA: Color
    let colorB: Color
    let colorC: Color
    let tilt: Double
}

let glassThemes: [GlassTheme] = [
    GlassTheme(colorA: Color(red: 0.98, green: 0.25, blue: 0.15), colorB: Color(red: 1.0, green: 0.65, blue: 0.1), colorC: Color(red: 1.0, green: 0.9, blue: 0.2), tilt: -14),
    GlassTheme(colorA: Color(red: 0.98, green: 0.85, blue: 0.2), colorB: Color(red: 1.0, green: 0.5, blue: 0.1), colorC: Color(red: 0.9, green: 0.95, blue: 0.4), tilt: 7),
    GlassTheme(colorA: Color(red: 0.15, green: 0.85, blue: 0.7), colorB: Color(red: 0.1, green: 0.4, blue: 0.95), colorC: Color(red: 0.6, green: 0.95, blue: 0.3), tilt: 9)
]
