import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    
    var foregroundColor: Color = .black
    var backgroundColor: Color = Color("background")
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            
            configuration.label
                .font(Settings.fontMedium.bold())
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(foregroundColor)
        }
        .shadow(radius: 5)
        .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}
