//
//  AppDelegate.swift
//  YXChatUI
//
//  Created by yuan yu on 2024/5/16.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        window?.rootViewController = UINavigationController.init(rootViewController: ViewController())
        
        return true
    }


}

