//
//  TodayView.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 22.04.2022.
//

import SwiftUI

struct TodayView: View {
    
    @EnvironmentObject var viewModel: XKCDViewModel
    @EnvironmentObject var imageService: ImageService

    @State private var comics: XKCDComics?
    @State private var image = UIImage()
    @State private var number: Int = 2000

    @State var receivedError = false
    @State var errorDetails: String = "" {
        didSet { receivedError = true }
    }
    
    var body: some View {
        VStack {
            Group {
                if let comics = comics {
                    ComicsView(title: comics.title,
                               image: image,
                               description: comics.text)
                    .padding()

                    Spacer()
                    ControlsView(
                        max: viewModel.maxNumber,
                        currentIndex: $number
                    )
                    .padding()
                } else {
                    ProgressView()
                }
            }

        }
        .alert("Error", isPresented: $receivedError, actions: {
            Button(":(", role: .cancel) { }
        }, message: {
            Text(errorDetails)
        })
        .task(id: number) {
            do {
                comics = try await viewModel.download(withNumber: number)
                image = try await imageService.downloadImage(fromURL: comics!.imageURL!)
            } catch {
                errorDetails = error.localizedDescription
            }
        }
    }
}
