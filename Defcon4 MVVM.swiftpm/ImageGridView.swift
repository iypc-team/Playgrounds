// 
// 

import SwiftUI

struct ImageGridView: View {
    let pngFileURLs: [URL]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 10) {
                ForEach(pngFileURLs, id: \.self) { url in
                    if let uiImage = UIImage(contentsOfFile: url.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .border(Color.gray, width: 1)
                            .overlay(
                                Text(url.lastPathComponent)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.7))
                                    .padding(2),
                                alignment: .bottom
                            )
                    }
                }
            }
            .padding()
        }
        .frame(width: 200, height: 200)  // Adjust height as needed
    }
}
