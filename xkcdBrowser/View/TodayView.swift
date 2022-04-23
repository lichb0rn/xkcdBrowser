//
//  TodayView.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 22.04.2022.
//

import SwiftUI

struct TodayView: View {
    
    let model: XKCDViewModel
    
    @State var title: String = ""
    @State var imageUrl: URL?
    @State var text: String = ""
    
    @State var receivedError = false
    @State var errorDetails: String = "" {
        didSet { receivedError = true }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .padding()
                
                AsyncImage(url: imageUrl) { image in
                    image
                } placeholder: {
                    ProgressView()
                }
            }
            .padding([.bottom], 100)

            Text(text)
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(width: 300)
            Spacer()
        }
        .alert("Error", isPresented: $receivedError, actions: {
            Button(":(", role: .cancel) { }
        }, message: {
            Text(errorDetails)
        })
        .task {
            do {
                let comics = try await model.fetchCurrentComics()
                title = comics.title
                imageUrl = comics.image
                text = comics.text
            } catch {
                errorDetails = error.localizedDescription
            }
        }
    }
}
