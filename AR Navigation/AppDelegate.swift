//
//  AppDelegate.swift
//  AR Navigation
//
//  Created by Murphy Zheng on 2018/12/7.
//  Copyright © 2018 mieasy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window!.makeKeyAndVisible()
        
        if #available(iOS 11.0, *) {
            let vc = ViewController()
            self.window!.rootViewController = vc
        }
        
        return true
    }
}

