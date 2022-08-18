import SwiftUI

struct WaitingView: View {
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text("Loading: \(progressString)%...")
                .foregroundColor(.black)
                .font(.headline)
            
            Image("estimation")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(
                    ZStack {
                        Color.black.opacity(0.2)
                        windowsProgressBar
                            .frame(height: 15)
                            .padding([.leading, .trailing], 16)
                    }
                )
        }
        .onReceive(timer) { _ in
            loadingProgress = CGFloat.random(in: 0..<1)
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
    
    // Windows-style loading progress :-)
    @State private var loadingProgress: CGFloat = 0
    private var progressString: String {
        String(format: "%1.0f", loadingProgress * 100)
    }
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var windowsProgressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: proxy.size.width , height: proxy.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color("background"))
                
                Rectangle()
                    .frame(width: min(CGFloat(loadingProgress) * proxy.size.width, proxy.size.width),
                           height: proxy.size.height)
                    .foregroundColor(Color("xkcdBlue"))
                
            }.cornerRadius(45.0)
        }
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView()
    }
}
