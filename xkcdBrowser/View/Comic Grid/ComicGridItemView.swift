import SwiftUI

struct ComicGridItemView: View {
    @EnvironmentObject var store: ComicStore
    
    let comic: Comic
    
    @State private var opacity: Double = 0
    @State private var image: Image = Image("estimation")
    @State private var isLoading: Bool = true
    
    var body: some View {
        content
            .overlay(alignment: .topTrailing) {
                BadgeView(text: "\(comic.id)",
                          textColor: .white,
                          badgeColor: comic.isViewed ? .gray : Settings.backgroundColor)
                .offset(x: -10, y: 10)
            }
            .border(comic.isViewed ? .gray : .black, width: 2)
            .task {
                await getImage(ofSize: CGSize(width: 200, height: 200))
            }
            .onAppear {
                opacity = comic.isViewed ? 0.7 : 1
            }
            .onDisappear {
                
            }
    }
    
    @ViewBuilder var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            GridItemImage(image: image)
        }
    }
    
    private func getImage(ofSize size: CGSize) async {
        if let uiImage = await store.downloadImage(for: comic, ofSize: size) {
            image = Image(uiImage: uiImage)
        } else {
            image = Image("error")
        }
        isLoading = false
    }
}

struct ComicsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let comicData = PreviewData().decodedJSON.last!
        var comicItem = Comic(entity: comicData, url: ComicEndpoint.byIndex(comicData.id).url)
        comicItem.markViewed()
        
        Task {
            try await ComicService.shared.setUp(fetcher: Fetcher(networking: MockNetworking()), storage: DiskStorage())
        }
        
        return ComicGridItemView(comic: comicItem).environmentObject(ComicStore(prefetchCount: 10, prefetchMargin: 5, comicService: ComicService.shared)).padding()
    }
}

