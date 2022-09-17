import SwiftUI

struct SplashScreen: View {
    enum AnimationPhase {
        case normal
        case small
        case large
        
        var scale: Double {
            switch self {
            case .normal: return 1
            case .small: return 0.7
            case .large: return 10
            }
        }
    }
    @State private var phase: AnimationPhase = .normal
    @State private var opacity: Double = 1
    private let delay: Double = 0.5
    
    var body: some View {
        ZStack {
            Color("background").edgesIgnoringSafeArea(.all)

            comicCard("xkcd-people")
                .scaleEffect(phase.scale)
                .opacity(opacity)
                
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring()) {
                    phase = .small
                    opacity = 0.7
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.spring()){
                            phase = .large
                            opacity = 0
                        }
                    }
                }
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
