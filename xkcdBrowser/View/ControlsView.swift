//
//  ControlsView.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 30.04.2022.
//

import SwiftUI

struct ControlsView: View {

    var min: Int
    var max: Int

    @Binding var currentIndex: Int

    @State private var leftEnabled: Bool
    @State private var rightEnabled: Bool

    init(min: Int = 0, max: Int, currentIndex: Binding<Int>) {
        self.min = min
        self.max = max
        self._currentIndex = currentIndex
        self._leftEnabled = State(initialValue: currentIndex.wrappedValue > min)
        self._rightEnabled = State(initialValue: currentIndex.wrappedValue < max)
    }

    var body: some View {
        HStack {
            Button {
                if currentIndex > min {
                    currentIndex -= 1
                } else {
                    currentIndex = min
                    leftEnabled = false
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!leftEnabled)

            Spacer()

            Button {
                if currentIndex < max {
                    currentIndex += 1
                } else {
                    currentIndex = max
                    rightEnabled = false
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!rightEnabled)
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(max: 2000, currentIndex: .constant(1000))
            .padding()
    }
}
