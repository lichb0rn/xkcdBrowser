//
//  Main.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 23.04.2022.
//

import SwiftUI

struct MainView: View {
    
    let viewModel = XKCDViewModel()
    
    var body: some View {
        TabView {
            TodayView(model: viewModel)
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
    }
}

