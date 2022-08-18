import SwiftUI

struct MainView: View {
//
//    #if DEBUG
//    @StateObject var store = ComicStore(fetcher: Fetcher(networking: MockNetworking()))
//    #else
//    @StateObject var store = ComicStore()
//    #endif
    
    @StateObject var store: ComicStore
    @State private var showSplashScreen = true
    
    private let appContainer: AppContainer
    
    init() {
        appContainer = AppContainer()
        let store = appContainer.initStore()
        self._store = StateObject(wrappedValue: store)
    }
    
    var body: some View {
        contentView.environmentObject(store)
            .task {
                await store.fetch()
            }
    }
    
    @ViewBuilder private var contentView: some View {
        if showSplashScreen {
            SplashScreen()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSplashScreen = false
                    }
                }
        } else {
            Group {
                if store.showError {
                    ErrorView()
                } else {
                    ComicGridView()
                        .environmentObject(store)
                }
            }
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return MainView()
    }
}
