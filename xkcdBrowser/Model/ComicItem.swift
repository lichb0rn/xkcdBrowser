import SwiftUI

// A type that represents data in the grid
struct ComicItem {
    let id = UUID()
    let downloader: ImageDownloader
    
    private var isFetchingImage: Bool
    var comicData: XKCDComic
    var comicImage: Image?
    
    var isViewed: Bool = false
    var isFavorite: Bool = false
    
    init(downloader: ImageDownloader, comicData: XKCDComic, comicImage: Image? = nil) {
        self.downloader = downloader
        self.isFetchingImage = false
        self.comicData = comicData
        self.comicImage = comicImage
    }
    
    var num: Int {
        comicData.num
    }
    
    mutating func fetchImage() async {
        guard !isFetchingImage else { return }
        isFetchingImage = true
        do {
            let uiImage = try await downloader.downloadImage(fromURL: comicData.imageUrl)
            comicImage = Image(uiImage: uiImage)
        } catch {
            print(error.localizedDescription)
        }
        isFetchingImage = false
    }
}

extension ComicItem: Identifiable, Hashable {
    static func == (lhs: ComicItem, rhs: ComicItem) -> Bool {
        lhs.num == rhs.num
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(num)
    }
}


extension ComicItem {
    static var preview: [ComicItem] = {
        let downloader = MockImageService()
        let previewData = PreviewData()
        
        var items: [ComicItem] = previewData.jsons.map { comic in
            
            var item = ComicItem(downloader: downloader, comicData: comic)
            item.comicImage = Image(uiImage: downloader.loadFromFile(comic.imageUrl)!)
            return item
        }
        
        return items
    }()
}
