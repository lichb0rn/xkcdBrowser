import SwiftUI

struct ComicGridItemView: View {
    @EnvironmentObject var store: ComicStore
    
    private let comic: Comic
    
    @State private var opacity: Double = 0
    @State private var image: Image = Image("estimation")
    
    init(comic: Comic) {
        self.comic = comic
    }
    
    var body: some View {
        comicView(image)
            .overlay(alignment: .topTrailing) {
                BadgeView(text: "\(comic.id)",
                          textColor: .white,
                          badgeColor: comic.isViewed ? .gray : Settings.backgroundColor)
                .offset(x: -10, y: 10)
            }
            .border(comic.isViewed ? .gray : .black, width: 2)
            .task {
                await getImage()
            }
            .onChange(of: image) { _ in
                opacity = 1
            }
    }
    
    func comicView(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
            .aspectRatio(1, contentMode: .fit)
            .opacity(opacity)
            .animation(.easeInOut(duration: 1), value: opacity)
            .padding()
            .onAppear {
                opacity = comic.isViewed ? 0.7 : 1
            }
    }
    
    private func getImage() async {
        if let uiImage = await store.downloadImage(for: comic) {
            image = Image(uiImage: uiImage)
        } else {
            image = Image("error")
        }
    }
}

struct ComicsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let comicData = PreviewData().decodedJSON.last!
        var comicItem = Comic(comicData: comicData)
        comicItem.markViewed()
        return ComicGridItemView(comic: comicItem).environmentObject(ComicStore(fetcher: MockAPIFetcher())).padding()
    }
}
