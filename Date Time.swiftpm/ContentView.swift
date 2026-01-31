//  Date Time  01/31/2026-1
//  ContentView.swift
//  
//  https://github.com/iypc-team/Playgrounds/tree/main/Date%20Time.swiftpm
//  
//  

import SwiftUI

struct ContentView: View {
    let fdt =  FormatDateTime()
    
    var body: some View {
        VStack {
            Image(systemName: "apple.logo")
                .padding(20)
                .imageScale(.large)
                .foregroundColor(.red)
                .font(.system(size: 98, weight: .black, design: .default))
            
            Text(("Created on \(fdt.fullDate() )"))
//            Text(fdt.onlyTime())
            Text("at: \(fdt.onlyTime() )")
            Text("")
            
//            Text("Took \(time.components.seconds)")
            //  
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

