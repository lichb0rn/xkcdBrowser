import SwiftUI

struct ComicGridItemView: View {
    
    @ObservedObject var viewModel: ComicGridItemViewModel
    
    @State private var opacity: Double = 0

    
    var body: some View {
        VStack(alignment: .center) {
            if let comicInfo = viewModel.comic.comicData {
                if !viewModel.isFetching, let comicImage = viewModel.comic.comicImage {
                    comicImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1), value: opacity)
                        .padding()
                        .onAppear {
                            opacity = 1
                            timer.upstream.connect().cancel()
                        }
                }
                Text(comicInfo.title)
                    .font(.body)
                    .lineLimit(1)
                
                Text("#\(comicInfo.num)")
                    .font(.footnote)
                
            }
            else {
                waitingView
            }
        }
        .border(.black, width: 2)
        .onAppear {
            if !viewModel.isFetching {
                opacity = 1
            }
        }
        .onReceive(timer) { _ in
            loadingProgress = CGFloat.random(in: 0..<100)
        }
    }
    
    var waitingView: some View {
        VStack(alignment: .center) {
            Spacer()
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
            Spacer()
        }
    }
    
    // Windows style loading progress :-)
    @State private var loadingProgress: CGFloat = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var windowsProgressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: proxy.size.width , height: proxy.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color("background"))
                
                Rectangle().frame(width: min(CGFloat(loadingProgress) * proxy.size.width, proxy.size.width),
                                  height: proxy.size.height)
                    .foregroundColor(Color("xkcdBlue"))
            }.cornerRadius(45.0)
        }
    }
}

struct ComicsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let comicItem = ComicItem(downloader: MockImageService())
        let viewModel = ComicGridItemViewModel(comic: comicItem)
        
        return ComicGridItemView(viewModel: viewModel)
    }
}
