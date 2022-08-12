import SwiftUI

struct ComicGridItemView: View {
    
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
                          badgeColor: Settings.backgroundColor)
                .offset(x: -10, y: 10)
            }
            .border(.black, width: 2)
            .task {
                do {
                    let uiImage = try await ImageService.shared.downloadImage(fromURL: comic.imageURL)
                    self.image = Image(uiImage: uiImage)
                } catch {
                    
                }
            }
            .saturation(comic.isViewed ? 0.2 : 1)
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
                opacity = 1
            }
    }
    
    
}

struct ComicsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let comicData = PreviewData().decodedJSON.last!
        var comicItem = Comic(comicData: comicData)
        comicItem.isViewed = true
        return ComicGridItemView(comic: comicItem).padding()
    }
}
