import SwiftUI

struct MainView: View {
//
//    #if DEBUG
//    @StateObject var store = ComicStore(fetcher: Fetcher(networking: MockNetworking()))
//    #else
//    @StateObject var store = ComicStore()
//    #endif
    
    @StateObject var store = ComicStore()
    
    var body: some View {
        contentView.environmentObject(store)
            .task {
                await store.fetch()
            }
    }
    
    @ViewBuilder private var contentView: some View {
        switch store.state {
        case .completed:
            ComicGridView()
        case .fetching:
            WaitingView()
        case .error:
            ErrorView()
        default:
            WaitingView()
        }
    }
}

