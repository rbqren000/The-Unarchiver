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

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(message: "open url:\(url.absoluteString)")
        if url.absoluteString.contains("/Documents/Inbox/") {
            let alertController = QMUIAlertController.init(title: url.lastPathComponent, message: "此文件存储在「文件/Inbox」中，是否打开", preferredStyle: .alert)
            alertController.addCancelAction()
            alertController.addAction(QMUIAlertAction.init(title: "打开", style: .destructive, handler: { _, _ in
                let controller = DocumentsViewController()
                controller.indexFileURL = url.deletingLastPathComponent()
                controller.title = url.deletingLastPathComponent().lastPathComponent
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: controller, action: #selector(controller.dismissController))
                let nav = QMUINavigationController.init(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                kAppRootViewController?.present(nav, animated: true, completion: nil)
            }))
            alertController.showWith(animated: true)
        }
        return true
    }
    
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
