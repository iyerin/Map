//
//  AppDelegate.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/8/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let myparser = Parser()
        let regions = myparser.myparser()
        
        window = UIWindow()
        let myController = FirstViewController()
        myController.regions = regions
        myController.index = 0
        let navigation = UINavigationController(rootViewController: myController)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        return true
    }
}

