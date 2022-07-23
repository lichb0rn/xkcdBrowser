import SwiftUI

struct ControlBar: View {
    
    var text: String
    @Binding var altTapped: Bool
    let onShareTap: () -> Void
    
    var body: some View {
        HStack {            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    onShareTap()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Button {
                    altTapped.toggle()
                } label: {
                    Image(systemName: "questionmark")
                        .font(.headline)
                }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
}


struct ControlBar_Previews: PreviewProvider {
    static var previews: some View {
        ControlBar(text: "1234", altTapped: .constant(false), onShareTap: {})
    }
}
