//   MethodViewModel.swift
//  

import SwiftUI

final class MethodViewModel: ObservableObject {
    @Published var methods: [String] = []
    let framework: Framework
    
    // Built‑in defaults so the list never stays empty
    private let defaultMethods: [String: [String]] = [
        "SwiftUI": [
            "Text(_:)", "Image(_:)", "Button(_:action:)",
            "VStack(alignment:spacing:content:)", "HStack(alignment:spacing:content:)",
            "ZStack(alignment:content:)", "List(_:rowContent:)",
            "NavigationStack(_:)", "NavigationLink(_:value:)"
        ],
        "UIKit": [
            "UIView.init(frame:)", "UIViewController.viewDidLoad()",
            "UIViewController.present(_:animated:completion:)", "UITableView.init(frame:style:)"
        ],
        "Foundation": [
            "Date()", "URL.init(string:)", "Data.init(contentsOf:)",
            "JSONDecoder.decode(_:from:)"
        ],
        "Combine": [
            "Just.init(_:)", "Publisher.map(_:)", "Publisher.sink(receiveCompletion:receiveValue:)"
        ]
    ]
    
    init(framework: Framework) {
        self.framework = framework
        Task { await fetchMethods() }
    }
    
    @MainActor
    func fetchMethods() async {
        let currentLibrary = framework.name
        
        // Try bundled JSON: methods.json shaped as { "SwiftUI": [ ... ], "UIKit": [ ... ] }
        if
            let url = Bundle.main.url(forResource: "methods", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]],
            let loaded = json[currentLibrary]
        {
            methods = loaded
            return
        }
        
        // Fallback to built‑in defaults or a friendly message
        methods = defaultMethods[currentLibrary] ?? ["No methods available for this framework"]
    }
}
