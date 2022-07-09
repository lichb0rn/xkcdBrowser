import SwiftUI


class ComicDetailsViewModel: ObservableObject {
    
    private var comic: ComicItem

    @Published private(set) var isFetching: Bool = false
    @Published private(set) var image: Image = Image("estimation")
    var num: String {
        "#\(comic.comicData.num)"
    }
    var title: String {
        comic.comicData.title
    }
    var text: String {
        comic.comicData.text
    }
    
    init(comic: ComicItem) {
        self.comic = comic
        
        Task {
            await fetchImage()
        }
    }
    
    @MainActor
    func fetchImage() async {
        guard !isFetching else { return }
        
        isFetching = true
        await comic.fetchImage()
        if let img = comic.comicImage {
            self.image = img
        }
        isFetching = false
    }
}
