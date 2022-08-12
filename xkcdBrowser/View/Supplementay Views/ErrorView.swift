import SwiftUI

struct ErrorView: View {
    let title: String
    let image: Image
    let text: String

    init(title: String = "Server Problem", image: Image = Image("serverProblem"), text: String = "Maybe server is busy. Try again later.") {
        self.title = title
        self.image = image
        self.text = text
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .padding()
            image
                .resizable()
                .scaledToFit()
                .padding()
            Text(text)
                .font(.headline)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
