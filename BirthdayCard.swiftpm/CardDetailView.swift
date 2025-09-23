import SwiftUI

struct CardDetail: View {
    static let image = Image("Carrier")
    @State private var zoomed = false
    var body: some View {
        CardDetail.image
            .resizable()
            .aspectRatio(contentMode: zoomed ? .fit : .fill)
            .onTapGesture {
                withAnimation {
                    zoomed.toggle()
                }
            }
    }
}

//struct AspectRatioView: View {
//    let contentMode: ContentMode?
//    var body: some View {
//        return contentMode
//    }
//}

struct CardDetail_Previews: PreviewProvider {
    static var previews: some View {
        CardDetail()
            .preferredColorScheme(.dark)
//        print("\(CardDetail)")
    }
}
