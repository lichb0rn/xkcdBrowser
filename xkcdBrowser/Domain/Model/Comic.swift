import SwiftUI

// A type that represents data in the grid
struct Comic {
    let id = UUID()
    let downloader: ImageDownloader
    
    private var isFetchingImage: Bool
    var comicData: ComicAPIEntity
    var comicImage: Image?
    
    var isViewed: Bool = false
    var isFavorite: Bool = false
    
    init(downloader: ImageDownloader, comicData: ComicAPIEntity, comicImage: Image? = nil) {
        self.downloader = downloader
        self.isFetchingImage = false
        self.comicData = comicData
        self.comicImage = comicImage
    }
    
    var comicID: Int {
        comicData.id
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

extension Comic: Identifiable, Hashable {
    static func == (lhs: Comic, rhs: Comic) -> Bool {
        lhs.comicID == rhs.comicID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(comicID)
    }
}


extension Comic {
    static var preview: [Comic] = {
        let downloader = MockImageService()
        let previewData = PreviewData()
        
        var items: [Comic] = previewData.jsons.map { comic in
            
            var item = Comic(downloader: downloader, comicData: comic)
            item.comicImage = Image(uiImage: downloader.loadFromFile(comic.imageUrl)!)
            return item
        }
        
        return items
    }()
}
