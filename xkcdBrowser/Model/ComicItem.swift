import SwiftUI

// A type that represents data in the grid
struct ComicItem {
    let id = UUID()
    let downloader: ImageDownloader
    
    var comicData: XKCDComic?
    var comicImage: Image?
    
    var num: Int {
        comicData?.num ?? 0
    }
    
    mutating func fetchImage() async {
        guard let comicData = comicData else { return }
        do {
            let uiImage = try await downloader.downloadImage(fromURL: comicData.imageUrl)
            comicImage = Image(uiImage: uiImage)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ComicItem: Identifiable { }


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
