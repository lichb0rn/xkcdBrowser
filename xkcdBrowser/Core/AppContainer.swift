import Foundation
import UIKit

final class AppContainer {
    
    func initStore() -> ComicStore {
        let prefetchMargin: Int
        let prefetchCount: Int
        if UIDevice.current.userInterfaceIdiom == .pad {
            prefetchCount = 30
            prefetchMargin = 10
        } else {
            prefetchCount = 10
            prefetchMargin = 5
        }
        
        return ComicStore(prefetchCount: prefetchCount, prefetchMargin: prefetchMargin)
    }
    
}
