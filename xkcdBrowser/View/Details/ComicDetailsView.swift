import SwiftUI

struct ComicDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ComicDetailsViewModel
    
    @State private var showPopup: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                viewModel.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1 + currentScale)
                    .offset(panOffset)
                    .gesture(doubleTapToZoom())
                    .gesture(isScaled ? panGesture() : nil)
                    .gesture(zoomGesture())
                
                Spacer()
                
                ControlBar(text: viewModel.num, altTapped: $showPopup) {
                    shareComic()
                }
                .opacity(currentScale > minScale ? 0 : 1)
                
            }
            .padding()
            
            if showPopup {
                GeometryReader { proxy in
                    PopupView(text: viewModel.text, isShowing: $showPopup)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(showPopup)
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.title)
                    .font(Settings.fontLarge)
            }
        })
    }
    
    // MARK: - Gestures
    
    // MARK: Zoom
    private let maxScale: CGFloat = 1.5
    private let minScale: CGFloat = 0
    @State private var currentScale: CGFloat = 0
    
    // Pinch to zoom
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { newScale in
                currentScale = newScale - maxScale
            }
            .onEnded { newScale in
                withAnimation(.easeInOut) {
                    currentScale = minScale
                }
            }
    }
    
    // Double tap to zoom
    private var isScaled: Bool {
        currentScale == maxScale
    }
    
    private func doubleTapToZoom() -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.easeInOut) {
                    currentScale = isScaled ? minScale : maxScale
                }
            }
    }
    
    // Pan gesture
    @State private var initialPanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (initialPanOffset + gesturePanOffset) * currentScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { newValue, gesturePanOffset, _ in
                gesturePanOffset = newValue.translation / currentScale
            }
            .onEnded { finalValue in
                initialPanOffset = initialPanOffset + (finalValue.translation / currentScale)
            }
    }
    
    
    // MARK: - Share
    
    private func shareComic() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        
        let share = UIActivityViewController(activityItems: [viewModel.linkForShare], applicationActivities: nil)
        windowScene?.keyWindow?.rootViewController?.present(share, animated: true, completion: nil)
    }
}

struct ComicsDetailsView_Previews: PreviewProvider {
    static let comicItem = ComicItem.preview.first!
    static let viewModel = ComicDetailsViewModel(comic: comicItem)
    
    static var previews: some View {
        NavigationView {
            ComicDetailsView(viewModel: viewModel)
        }
    }
}


extension CGSize {
    var center: CGPoint {
        CGPoint(x: width/2, y: height/2)
    }
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
}
