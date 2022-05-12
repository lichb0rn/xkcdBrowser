//
//  Main.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 23.04.2022.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var viewModel = XKCDViewModel()
    @StateObject var imageService = ImageService()
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Latest")
                }
            
            ComicsListView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("More")
                }
        }
        .environmentObject(viewModel)
        .environmentObject(imageService)
    }
}

