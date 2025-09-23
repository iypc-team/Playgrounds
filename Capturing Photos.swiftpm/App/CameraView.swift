import SwiftUI

/*#-code-walkthrough(cv.intro)*/
struct CameraView: View {
/*#-code-walkthrough(cv.intro)*/
    /*#-code-walkthrough(cv.observedObject)*/
    @StateObject private var model = DataModel()
    /*#-code-walkthrough(cv.observedObject)*/
 
    private static let barHeightFactor = 0.15
    
    /*#-code-walkthrough(delayedShutter.delayCount)*/
    /*#-code-walkthrough(delayedShutter.delayCount)*/
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                /*#-code-walkthrough(previewflow.viewPreviews)*/
                ViewfinderView(image: /*#-code-walkthrough(previewflow.binding)*/ $model.viewfinderImage /*#-code-walkthrough(previewflow.binding)*/)
                /*#-code-walkthrough(previewflow.viewPreviews)*/
                    .overlay(alignment: .top) {
                        Color.black
                            .opacity(0.75)
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                    }
                    .overlay(alignment: .bottom) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.black.opacity(0.75))
                    }
                    .overlay(alignment: .center)  {
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .background(.black)
            }
            .task {
                await model.camera.start()
                await model.loadPhotos()
                await model.loadThumbnail()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Spacer()
            
            /*#-code-walkthrough(navigateToGallery.entireLink)*/
            /*#-code-walkthrough(navigateToGallery.link)*/
            NavigationLink {
                /*#-code-walkthrough(navigateToGallery.photoCollection)*/
                PhotoCollectionView(photoCollection: model.photoCollection)
                /*#-code-walkthrough(navigateToGallery.photoCollection)*/
                /*#-code-walkthrough(navigateToGallery.link)*/
                    /*#-code-walkthrough(navigateToGallery.onAppear)*/
                    .onAppear {
                        model.camera.isPreviewPaused = true
                    }
                    .onDisappear {
                        model.camera.isPreviewPaused = false
                    }
                    /*#-code-walkthrough(navigateToGallery.onAppear)*/
            } label: {
                Label {
                    Text("Gallery")
                } icon: {
                    ThumbnailView(image: model.thumbnailImage)
                }
            }
            /*#-code-walkthrough(navigateToGallery.entireLink)*/
            
            /*#-code-walkthrough(photoflow.shutterButton)*/
            Button {
                /*#-code-walkthrough(photoflow.shutterButton)*/
                /*#-code-walkthrough(photoflow.shutterButtonAction)*/
                model.camera.takePhoto()
                /*#-code-walkthrough(photoflow.shutterButtonAction)*/
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                        /*#-code-walkthrough(delayedShutter.icon)*/
                        /*#-code-walkthrough(delayedShutter.icon)*/
                    }
                }
            }
            
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
    
}
