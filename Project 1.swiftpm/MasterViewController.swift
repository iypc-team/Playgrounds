////
////  MasterViewController.swift
////  Project1
////
////  Created by Hudzilla on 13/09/2015.
////  Copyright © 2015 Paul Hudson. All rights reserved.
////
//
//import UIKit
//
//class MasterViewController: UITableViewController {
//    
//    var detailViewController: DetailViewController? = nil
//    var objects = [String]()
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let fm = FileManager.default
//        let path = Bundle.main.resourcePath!
//        let items = try! fm.contentsOfDirectoryAtPath(path)
//        
//        for item in items {
//            if item.hasPrefix("nssl") {
//                objects.append(item)
//            }
//        }
//    }
//}
