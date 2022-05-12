//
//  ComicsView.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 30.04.2022.
//

import SwiftUI

struct ComicsView: View {
    
    let title: String
    let image: UIImage
    let description: String
    
    var body: some View {
        VStack {
            VStack {
                Text(title)
                    .font(.headline)
                    .padding()

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            Text(description)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
        }
    }
}

//struct ComicsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ComicsView(
//            title: "Woodpecker",
//            imageURL: "https://imgs.xkcd.com/comics/woodpecker.png",
//            description: "If you don't have an extension cord I can get that too.  Because we're friends!  Right?")
//        .padding()
//    }
//}
