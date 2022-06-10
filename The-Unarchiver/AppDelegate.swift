//
//  AppDelegate.swift
//  The-Unarchiver
//
//  Created by SWING - on 2022/6/9.
//

import UIKit
import SwiftDate
import Alamofire
import Async
import QMUIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureApp()
        configureAppearance()
        application.isIdleTimerDisabled = true
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = TabBarViewController()
        window?.makeKeyAndVisible()
        return true
    }

//    func rootViewController() -> UIViewController {
//        return UINavigationController(rootViewController: )
//    }
}

extension AppDelegate {
    func configureApp() {

        SwiftDate.defaultRegion = Region.local
        Async.background {
            FileManager.default.createDefaultDirectory()
        }
    }
    func configureAppearance() {
        if #available(iOS 15.0, *) {
            let tabbarAppearance = UITabBarAppearance()
            tabbarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabbarAppearance
            
            let barAppearance =  UINavigationBarAppearance()
            barAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = barAppearance            
        }
        UINavigationBar.appearance().isTranslucent = false
//        UITabBar.appearance().tintColor = kButtonColor
        UITabBar.appearance().tintColor = UIColor.black

    }
}
