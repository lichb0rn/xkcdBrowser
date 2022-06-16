import SwiftUI



@MainActor
class ComicListItemViewModel: ObservableObject {

    let comic: XKCDComic
    private let imageService: ImageDownloader


    @Published var title: String = ""
    @Published var image: Image = Image("error")
    @Published var number: String = ""
    @Published var alt: String = ""
    @Published var isLoading: Bool = true

    let id: Int
    
    init(comic: XKCDComic, imageService: ImageDownloader = ImageService.shared) {
        self.imageService = imageService
        self.comic = comic
        self.title = comic.title
        self.alt = comic.text
        self.number = "#" + String(comic.id)
        self.id = comic.id
    }

    func fetch() async {
        isLoading = true
        do {
            let uiImage = try await imageService.downloadImage(fromURL: comic.imageUrl)
            image = Image(uiImage: uiImage)
        } catch {
            title = "Something went wrong... :("
            image = Image("error")
        }

        isLoading = false
    }
}

extension ComicListItemViewModel: Equatable, Hashable {
    static func == (lhs: ComicListItemViewModel, rhs: ComicListItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ComicListItemViewModel {
    convenience init(preview: Bool = true) {
        let comic = XKCDComic(id: 614,
                               text: "If you don't have an extension cord I can get that too.  Because we're friends!  Right?",
                               imageUrl: URL(string: "https://imgs.xkcd.com/comics/woodpecker.png")!,
                               title: "Woodpecker")
        self.init(comic: comic, imageService: MockImageService())
    }
}
