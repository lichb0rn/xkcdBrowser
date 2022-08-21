
import SwiftUI

struct GridItemImage: View {
    
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
            .aspectRatio(1, contentMode: .fit)
    }
}


struct GridItemImage_Previews: PreviewProvider {
    static var previews: some View {
        GridItemImage(image: Image("error"))
    }
}
