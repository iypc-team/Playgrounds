// 
// 

import SwiftUI

struct ImageGridView: View {
    let pngFileURLs: [URL]
    
    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], // Adaptive columns based on minimum size, adjust as needed
                spacing: 10
            ) {
                ForEach(pngFileURLs, id: \.self) { url in
                    if let uiImage = UIImage(contentsOfFile: url.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width / 4, height: geometry.size.width / 4) // Example: 4 columns, adjust based on desired matrix
                            .clipped() // Prevent overflow
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
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Use available space
    }
}
