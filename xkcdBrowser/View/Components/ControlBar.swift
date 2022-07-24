import SwiftUI

struct ControlBar: View {
    
    @State private var maxWidth: CGFloat = .zero
    
    
    var text: String
    @Binding var altTapped: Bool
    let onShareTap: () -> Void
    
    var body: some View {
        HStack {
                Button {
                    onShareTap()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        
                }
                .buttonStyle(RoundedButtonStyle(foregroundColor: .white))
                
                
                Button {
                    altTapped.toggle()
                } label: {
                    Text("ALT")
                }
                .buttonStyle(RoundedButtonStyle(foregroundColor: .white))
                
        }
        .fixedSize()
        .frame(maxWidth: .infinity)
    }
}




struct ControlBar_Previews: PreviewProvider {
    static var previews: some View {
        ControlBar(text: "1234", altTapped: .constant(false), onShareTap: {})
    }
}
