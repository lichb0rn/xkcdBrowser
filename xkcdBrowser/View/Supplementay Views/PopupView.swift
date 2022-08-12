import SwiftUI

struct PopupView: View {
    
    let text: String
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color("background").opacity(0.8).edgesIgnoringSafeArea(.all)
            
            Text(text)
                .padding(25)
                .frame(maxWidth: 450)
                .background(
                    Rectangle()
                        .foregroundColor(.white)
                    .border(.black, width: 2)
                        .padding()
                )
        }
        .onTapGesture {
            withAnimation {
                isShowing.toggle()
            }
        }
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(text: "If you don't have an extension cord I can get that too.  Because we're friends!  Right?",
                  isShowing: .constant(true))
    }
}
