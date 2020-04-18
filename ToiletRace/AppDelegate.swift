//
//  AppDelegate.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 02/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StoreProvider {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        isFirstTime()
        let firstVC = WelcomeVC()
        let nav = Navigation(rootViewController: firstVC)
        nav.navigationBar.isHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()

        return true
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let urlString = userActivity.webpageURL?.absoluteString, let range = urlString.range(of: "/race:") else { return true }
        let link = String(urlString[range.upperBound...])
        DeeplinkManager.shared.open(link)
        return true
    }
}
