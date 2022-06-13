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
        UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
        do {
            let moveToURL = FileManager.default.importFileDirectory.appendingPathComponent(url.lastPathComponent)
            if FileManager.default.fileExists(atPath: moveToURL.path) {
                try FileManager.default.removeItem(at: moveToURL)
            }
            try FileManager.default.moveItem(at: url, to: moveToURL)
            let alertController = QMUIAlertController.init(title: url.lastPathComponent, message: "该文件存储在「文件」中，是否查看?", preferredStyle: .alert)
            alertController.addCancelAction()
            alertController.addAction(QMUIAlertAction.init(title: "查看", style: .destructive, handler: { _, _ in
                let controller = DocumentsViewController()
                controller.indexFileURL = moveToURL.deletingLastPathComponent()
                controller.title = FileManager.default.importFileDirectory.lastPathComponent
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: controller, action: #selector(controller.dismissController))
                let nav = QMUINavigationController.init(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                kAppRootViewController?.present(nav, animated: true, completion: nil)
            }))
            alertController.showWith(animated: true)
            return true
        } catch _ {
            return false
        }
    }
    
}

extension AppDelegate {
    func configureApp() {

        SwiftDate.defaultRegion = Region.local
        Async.background {
            FileManager.default.createDefaultDirectory()
        }
        
        if AppDefaults.shared.alreadyInstalled! == false {
            AppDefaults.shared.reset()
            AppDefaults.shared.alreadyInstalled = true
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
