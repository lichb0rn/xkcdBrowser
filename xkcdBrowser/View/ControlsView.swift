//
//  ControlsView.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 30.04.2022.
//

import SwiftUI

struct ControlsView: View {
    
    var prevNumber: Int
    var nextNumber: Int? = nil
    
    var body: some View {
        HStack {
            Button {
                print("prev")
            } label: {
                HStack {
                    Text("\(Image(systemName: "arrow.left")) \(prevNumber)")
                }
            }
            Spacer()
            if let nextNumber = nextNumber {
                Button {
                    print("back")
                } label: {
                    HStack {
                        Text("\(nextNumber) \(Image(systemName: "arrow.right"))")
                    }
                }
            }
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(prevNumber: 2500, nextNumber: 2502)
            .padding()
    }
}
