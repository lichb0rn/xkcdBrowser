import SwiftUI

struct MainView: View {
    
    @StateObject var store: ComicStore
    @State private var showSplashScreen = true

    
    init() {
        self._store = StateObject(wrappedValue: AppFactory.initStore())
    }
    
    var body: some View {
        contentView
            .environmentObject(store)
            .task {
                await store.fetch()
            }
    }
    
    @ViewBuilder private var contentView: some View {
        if showSplashScreen {
            SplashScreen()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Settings.splashScreenDuration) {
                        withAnimation {
                            showSplashScreen = false
                        }
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
