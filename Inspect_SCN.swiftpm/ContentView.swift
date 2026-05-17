//  Inspect_SCN  05/17/2026-1
//  ContentView.swift — Opening Screen
//  Repo: https://github.com/iypc-team/Playgrounds/tree/main/Inspect_SCN.swiftpm
//  

import SwiftUI

// Shared darkGray used across the app
extension Color {
    static let appBackground = Color(UIColor.darkGray)
}

struct ContentView: View {
    @EnvironmentObject var viewModel: SceneViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 48) {
                    
                    // Title
                    VStack(spacing: 6) {
                        Text("Inspect SCN")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("SceneKit Inspector")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // File picker
                    VStack(spacing: 12) {
                        Text("Scene File")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        
                        Menu {
                            ForEach(viewModel.resourceFiles, id: \.self) { file in
                                Button(file) {
                                    guard file != viewModel.selectedFile else { return }
                                    viewModel.selectedFile = file
                                    viewModel.loadScene(for: file)
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedFile)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption.weight(.semibold))
                            }
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 18)
                            .background(Color.blue.opacity(0.65))
                            .cornerRadius(12)
                        }
                        .frame(maxWidth: 320)
                    }
                    
                    // Navigation buttons
                    VStack(spacing: 14) {
                        navRow(title: "Edit Materials",
                               icon: "paintbrush.pointed.fill",
                               color: .purple,
                               destination: EditMaterialsView())
                        
                        navRow(title: "Edit Geometry",
                               icon: "cube.fill",
                               color: .teal,
                               destination: EditGeometryView())
                        
                        navRow(title: "Export Files",
                               icon: "square.and.arrow.up.fill",
                               color: .green,
                               destination: ExportFilesView())
                    }
                }
                .padding(.horizontal, 32)
            }
            .navigationBarHidden(true)
        }
        // ✅ .onAppear is intentionally on the NavigationStack
        .onAppear {
            viewModel.loadResourceFiles()
            // Fixed: Use the return value to suppress the warning
            let _ = viewModel.loadScene(for: viewModel.selectedFile)
        }
    }
    
    @ViewBuilder
    private func navRow<D: View>(title: String, icon: String, color: Color, destination: D) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                    .font(.body.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(color.opacity(0.65))
            .cornerRadius(12)
            .frame(maxWidth: 320)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SceneViewModel())
    }
}
