import SwiftUI

struct AdaptiveGrid<Content: View, T: Identifiable & Hashable>: View {
    let cols: Int
    let spacing: CGFloat
    let content: (T) -> Content
    
    var gridItems: [T]
    
    init(columnsCount: Int = 3, spacing: CGFloat = 8, gridItems: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.cols = columnsCount
        self.spacing = spacing
        self.content = content
        self.gridItems = gridItems
    }
    
    func splitItems() -> [[T]] {
        var grid: [[T]] = Array(repeating: [], count: cols)
        
        var currentIndex = 0
        for item in gridItems {
            grid[currentIndex].append(item)
            
            if currentIndex == (cols  - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }
        
        return grid
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(splitItems(), id: \.self) { col in
                    LazyVStack(spacing: spacing) {
                        ForEach(col) { item in
                            content(item)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

//struct AdaptiveGrid_Previews: PreviewProvider {
//    static var items: [ComicGridItemViewModel] = {
//        var items = [ComicGridItemViewModel]()
//        
//        for comic in ComicItem.mockComics {
//            let vm = ComicGridItemViewModel(comic: comic)
//            vm.isFetching = false
//            items.append(vm)
//        }
//        
//        return items
//    }()
//    
//    static var previews: some View {
//        AdaptiveGrid(gridItems: items) { item in
//            ComicGridItemView(viewModel: item)
//        }
//    }
//}
