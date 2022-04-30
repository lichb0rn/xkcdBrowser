//
//  TodayView.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 22.04.2022.
//

import SwiftUI

struct TodayView: View {
    
    let model: XKCDViewModel
    @State var comics: XKCDComics?
    
    @State var title: String = ""
    @State var imageUrl: URL?
    @State var text: String = ""
    
    @State var receivedError = false
    @State var errorDetails: String = "" {
        didSet { receivedError = true }
    }
    
    var body: some View {
        VStack {
            ComicsView(title: title,
                       imageURL: imageUrl,
                       description: text)
            .padding()
            
            if let comics = comics {
                ControlsView(prevNumber: comics.number - 1, nextNumber: comics.number)
                    .padding()
            }
        }
        .alert("Error", isPresented: $receivedError, actions: {
            Button(":(", role: .cancel) { }
        }, message: {
            Text(errorDetails)
        })
        .task {
            do {
                comics = try await model.fetchCurrentComics()
                title = comics?.title ?? ""
                imageUrl = comics?.image
                text = comics?.text ?? ""
            } catch {
                errorDetails = error.localizedDescription
            }
        }
    }
}
