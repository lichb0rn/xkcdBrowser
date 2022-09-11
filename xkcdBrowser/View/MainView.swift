import SwiftUI

struct MainView: View {
    
    @StateObject var store: ComicStore
    @State private var showSplashScreen = true
    
    private let appFactory: AppFactory
    
    init() {
        appFactory = AppFactory()
        let store = appFactory.initStore()
        self._store = StateObject(wrappedValue: store)
    }
    
    var body: some View {
        contentView
            .environmentObject(store)
            .task {
                do{
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + Settings.splashScreenDuration) {
                        showSplashScreen = false
                    }
                }
        } else {
            if store.showError {
                ErrorView()
            } else {
                NavigationView {
                    ComicGridView()
                        .environmentObject(store)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return MainView()
    }
}
