import SwiftUI

struct MainView: View {
    
    @StateObject var store: ComicStore
    @State private var showSplashScreen = true
    
    private let appFactory: AppFactory
    
    init() {
        appFactory = AppFactory()
        var store: ComicStore
        store = appFactory.initStore()
        self._store = StateObject(wrappedValue: store)
    }
    
    var body: some View {
        contentView.environmentObject(store)
            .task {
                do{
//                    try await ComicService.shared.setUp(fetcher: Fetcher(), storage: DiskStorage())
                    try await appFactory.initProdStorageService()
                    await store.fetch()
                } catch {
                    print(error.localizedDescription)
                }
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
