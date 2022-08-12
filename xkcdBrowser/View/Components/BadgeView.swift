import SwiftUI

struct BadgeView: View {
    
    let text: String
    let textColor: Color
    let badgeColor: Color
    
    var body: some View {
            Text(text)
            .font(Settings.fontMedium)
                .foregroundColor(textColor)
                .padding()
                .background(badgeColor)
                .clipShape(Circle())
                .shadow(radius: 5)
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView(text: "#625", textColor: .white, badgeColor: Settings.backgroundColor)
        
    }
}
