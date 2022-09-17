import SwiftUI

struct ComicDetailsView: View {
    @EnvironmentObject var store: ComicStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let comic: Comic
    
    @State private var showPopup: Bool = false
    @State private var isFavorite: Bool = false
    @State private var image: Image = Image("estimation")
    
    var body: some View {
        ZStack {
            VStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1 + currentScale)
                    .offset(panOffset)
                    .gesture(doubleTapToZoom())
                    .gesture(isScaled ? panGesture() : nil)
                    .gesture(zoomGesture())
                    .task {
                        await store.markAsViewed(comic)
                    }
                
                Spacer()
                
                ControlBar(text: "\(comic.id)", altTapped: $showPopup, favoriteTapped: $isFavorite) {
                    shareComic()
                }
                .opacity(currentScale > minScale ? 0 : 1)
                .onChange(of: isFavorite) { newValue in
                    Task {
                        await store.markFavorite(comic, newValue: newValue)
                    }
                }
                
            }
            .padding()
            
            if showPopup {
                GeometryReader { proxy in
                    PopupView(text: comic.description, isShowing: $showPopup)
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
                Text(comic.title)
                    .font(Settings.fontLarge)
            }
        })
        .onAppear {
            isFavorite = comic.isFavorite
        }
        .task {
            await getImage()
        }
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
        let link = comic.imageURL
        
        let share = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        windowScene?.keyWindow?.rootViewController?.present(share, animated: true, completion: nil)
    }
    
    
    private func getImage() async {
        if let uiImage = await store.downloadImage(for: comic, ofSize: .zero) {
            image = Image(uiImage: uiImage)
        } else {
            image = Image("error")
        }
    }
}

struct ComicsDetailsView_Previews: PreviewProvider {
    static let comicItem = PreviewData().decodedJSON.last!
    static let comic = Comic(entity: comicItem, url: ComicEndpoint.byIndex(comicItem.id).url)
    
    static var previews: some View {
        NavigationView {
            ComicDetailsView(comic: comic)
        }
    }
}



