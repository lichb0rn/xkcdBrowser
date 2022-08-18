import SwiftUI

private struct SplashAnimation: ViewModifier {
    @State private var isAnimating: Bool = true
    
    let finalXPosition: CGFloat
    let finalYPosition: CGFloat
    let delay: Double
    
    let screenHeight = UIScreen.main.bounds.size.height
    let screenWidth  = UIScreen.main.bounds.size.width
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: isAnimating ? 300 : .zero,
                y: isAnimating ? -700 : finalYPosition
            )
            .rotationEffect(
                isAnimating ? .zero :
                    Angle(degrees: Double.random(in: -50...50))
            )
            .animation( Animation.interpolatingSpring(
                mass: 0.2,
                stiffness: 80,
                damping: 5,
                initialVelocity: 0.0)
                .delay(delay), value: isAnimating)
            .onAppear { isAnimating = false }
    }
}

struct SplashScreen: View {
    let images = ["error", "estimation", "servierProblem", "xkcd-people" ]
    
    var body: some View {
        ZStack {
            Color("background").edgesIgnoringSafeArea(.all)
            
            ForEach(images.indices) { idx in
                comicCard(images[idx])
                    .modifier(SplashAnimation(finalXPosition: 0, finalYPosition: 300, delay: Double(idx) * 0.5))
            }
        }
    }
    
    func comicCard(_ imageName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .shadow(radius: 3)
                .frame(width: 120, height: 160)
                .foregroundColor(.white)
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 110)
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
