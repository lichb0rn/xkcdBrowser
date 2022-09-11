import SwiftUI

struct Settings {
    // Startup
    static let splashScreenDuration: Double = 1.5
    
    // Fonts
    static let fontMedium: Font = .custom("ChalkboardSE-Light", size: 16)
    static let fontLarge: Font = .custom("ChalkboardSE-Light", size: 20)
    static let fontSmall: Font = .custom("ChalkboardSE-Light", size: 14)
    
    // Coloring
    static let backgroundColor = Color("background")
    
    // Core
    static let iPhonePrefetchCount = 10
    static let iPhonePrefetchMargin = 5
    static let iPadPrefetchCount = 30
    static let iPadPrefetchMargin = 10
}


