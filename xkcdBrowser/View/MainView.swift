import SwiftUI

struct MainView: View {

//    #if DEBUG
//    @StateObject var comicsListViewModel = ComicGridViewModel(fetcher: MockFetcher())
//    #else
//    @StateObject var comicsListViewModel = ComicGridViewModel(fetcher: ComicFetcher())
//    #endif
    @StateObject var comicsListViewModel = ComicGridViewModel(fetcher: ComicFetcher())
    
    var body: some View {
        ComicGridView(viewModel: comicsListViewModel)
    }
}

