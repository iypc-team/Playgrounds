//  saveImage() called ... 
//  

import SwiftUI
import Foundation
import Combine
import PlaygroundSupport


struct ContentView: View {
    @StateObject var fm = FileManagerViewModel()
    
    var body: some View {
        VStack {
            Image(uiImage: fm.thisImage!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .topLeading)
                .border(.black, width: 2)
                .clipped()
                .padding(20)
            
            Text(fm.imageName)
            Text("size:\(String(describing: fm.thisImageSize!))")
            Text(fm.infoMessage)
                .padding()
                .multilineTextAlignment(.leading)
                .font(.system(size: 20, weight: .semibold, design: .default))
//                
//            let sizeConversion: CVarArg = fm.thisImageSize! as CVarArg
//            Text("\(sizeConversion)")
            Spacer()
        }
        
        HStack {
            Spacer()
            Button(action: { fm.saveImage() }, label: {
                Text("FM Save \n Image ")
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    .background(Color.green)
                    
            })
            
            Spacer()
            Button(action: { fm.deleteImage() }, label: {
                Text("FM Delete \n Image")
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .background(Color.red)
                    
            })
            Spacer()
        }
        .padding(10)
        .cornerRadius(10, antialiased: true)
        .font(.system(size: 20, weight: .semibold, design: .default))
        HStack {
            Spacer()
            Button(action: { fm.saveImage() }, label: {
                Text("FM Save \n Image ")
                    .foregroundColor(.white)
                    .background(Color.forestGreen)
            })
            
            Spacer()
            Button(action: { fm.deleteImagesFolder() }, label: {
                Text("FM Delete \n Folder")
                    .foregroundColor(.white)
                    .background(Color.cardinalRed)
            })
            Spacer()
        }
        .padding(10)
        .cornerRadius(10, antialiased: true)
        .font(.system(size: 20, weight: .semibold, design: .default))
    }
}

//struct ContentView_Provider: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .preferredColorScheme(.dark)
//    }
//}




