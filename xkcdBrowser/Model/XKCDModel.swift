
import Foundation
import SwiftUI


// Data returned from server
struct XKCDComic {
    var num: Int
    var text: String = ""
    var title: String = ""
    var imageUrl: URL
    var link: URL {
        imageUrl.deletingLastPathComponent()
    }
}

extension XKCDComic: Decodable {
    private enum CodingKeys: String, CodingKey {
        case num
        case title
        case imageUrl = "img"
        case text = "alt"
    }
}

extension XKCDComic: Identifiable {
    var id: Int {
        num
    }
}


// A type that represents data in the grid
struct ComicItem {
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


//extension ComicItem {
//    static var mockComics: [ComicItem] = {
//        let downloader = MockImageService()
//
//        var items: [ComicItem] = []
//        for i in 0...20 {
//            var comic = XKCDComic(num: Int.random(in: 1..<2000),
//                                  text: "Hello world",
//                                  title: "Hola",
//                                  imageUrl: URL(string: "https://imgs.xkcd.com/comics/woodpecker.png")!)
//            var ci = ComicItem(downloader: downloader)
//            ci.comicData = comic
////            ci.comicImage = Image(uiImage: MockImageService.images.randomElement()!)
//            ci.comicImage = Image("error")
//            items.append(ci)
//        }
//        
//        return items
//    }()
//}
