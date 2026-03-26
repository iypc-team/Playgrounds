//  AppDelegate.swift
// 

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    //  
    static var orientationLock = UIInterfaceOrientationMask.all // Default value
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
