import SwiftUI

struct MainView: View {

    #if DEBUG
    @StateObject var comicsListViewModel = ComicGridViewModel(fetcher: MockAPIFetcher())
    #else
    @StateObject var comicsListViewModel = ComicGridViewModel(fetcher: NetworkManager())
    #endif
    
    var body: some View {
        ComicGridView(viewModel: comicsListViewModel)
    }
}

