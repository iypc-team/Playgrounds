//  FileManager copy 03/01/2026-initial commit
//  ContentView.swift
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/FileManager.swiftpm
//  

import SwiftUI

/// Reusable button style for the file-manager buttons.
struct FMButtonStyle: ButtonStyle {
    var bg: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(bg.opacity(configuration.isPressed ? 0.85 : 1.0))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct ContentView: View {
    @StateObject var fm = FileManagerViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            // Image area with safe unwrap and placeholder
            Group {
                if let uiImage = fm.thisImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.top, 20)
            
            // Info texts
            Text(fm.imageName)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)
            
            if let size = fm.thisImageSize {
                // Use a simple, safe interpolation; change to ByteCountFormatter if size is numeric bytes
                Text("Size: \(size)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(fm.infoMessage)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Primary actions row
            HStack {
                Spacer()
                Button(action: { fm.saveImage() }) {
                    Text("Save\nImage")
                }
                .buttonStyle(FMButtonStyle(bg: Color.forestGreen))
                
                Spacer()
                Button(action: { fm.deleteImage() }) {
                    Text("Delete\nImage")
                }
                .buttonStyle(FMButtonStyle(bg: Color.cardinalRed))
                
                Spacer()
            }
            .padding(.vertical, 6)
            
            // Secondary actions row
            HStack {
                Spacer()
                Button(action: { fm.deleteImagesFolder() }) {
                    Text("Delete\nFolder")
                }
                .buttonStyle(FMButtonStyle(bg: Color.red))
                Spacer()
            }
        }
        .padding()
        // Accessibility hints (examples)
        .accessibilityElement(children: .contain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
    }
}
