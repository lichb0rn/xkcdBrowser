import Foundation

struct MockFetcher: ComicDownloader {


    let previewData = PreviewData()
    private let mockImageService: ImageDownloader = MockImageService()
    
    func fetchComicItem(withIndex index: Int) async throws -> ComicItem {
        let randomComic = index == 0 ? previewData.jsons.last! : previewData.comic(with: index)
        return ComicItem(downloader: mockImageService, comicData: randomComic)
    }

    func fetchNextComicItems(from index: Int, count: Int) async throws -> [ComicItem] {
        let items: [ComicItem] = previewData.jsons.map { comic in
            ComicItem(downloader: mockImageService, comicData: comic)
        }
        return items
    }
    
}
