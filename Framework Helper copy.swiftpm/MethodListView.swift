// MethodListView.swift
//  

import SwiftUI

struct MethodListView: View {
    @StateObject private var viewModel: MethodViewModel
    
    init(framework: Framework) {
        _viewModel = StateObject(wrappedValue: MethodViewModel(framework: framework))
    }
    
    var body: some View {
        VStack {
            Text("Methods for \(viewModel.framework.name)")
                .font(.largeTitle)
                .padding(.top)
            
            List(viewModel.methods, id: \.self) { method in
                Text(method)
            }
            .refreshable {
                await viewModel.fetchMethods()
            }
        }
        .navigationTitle(viewModel.framework.name)
        .task {
            // Runs on first render; ensures fetchMethods is called on transition
            await viewModel.fetchMethods()
        }
    }
}

// 
//import SwiftUI
//
//struct MethodListView: View {
//    @StateObject private var viewModel: MethodViewModel
//    
//    init(framework: Framework) {
//        _viewModel = StateObject(wrappedValue: MethodViewModel(framework: framework))
//    }
//    
//    var body: some View {
//        VStack {
//            Text("Methods for \(viewModel.framework.name)")
//                .font(.largeTitle)
//                .padding()
//            
//            List(viewModel.methods, id: \.self) { method in
//                Text(method)
//            }
//            .refreshable {
//                
//                await viewModel.fetchMethods()
//            }
//            .navigationTitle(viewModel.framework.name)
//        }
//        .onAppear {
//            // Remove debug prints or gate them behind a debug flag
//            // print("struct MethodListView: View")
//            // print(".onAppear")
//        }
//    }
//}
