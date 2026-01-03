// 
// 

import SwiftUI

struct ImageGridView: View {
    let pngFileURLs: [URL]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.size.width / 3))], spacing: 10) {
                    ForEach(pngFileURLs, id: \.self) { url in
                        if let uiImage = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width / 3, height: geometry.size.width / 3)
                                .border(Color.gray, width: 1)
                                .overlay(
                                    Text(url.lastPathComponent)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.7))
                                        .padding(2),
                                    alignment: .bottom
                                )
                        } else {
                            // Placeholder for failed loads
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width / 3, height: geometry.size.width / 3)
                                .overlay(Text("Failed to load").font(.caption))
                        }
                    }
                }
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        // Removed edgesIgnoringSafeArea for better layout
    }
}
