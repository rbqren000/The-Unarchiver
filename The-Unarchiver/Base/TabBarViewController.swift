//
//  TabBarViewController.swift
//  ABox
//
//  Created by YZL-SWING on 2020/11/16.
//

import UIKit

class TabBarViewController: QMUITabBarViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        let appController = AppsViewController()
        appController.title = "Apps"
        let appsNav = QMUINavigationController(rootViewController: appController)
        appsNav.tabBarItem = UITabBarItem.init(title: "Apps", image: UIImage.init(named: "tabbar_source"), tag: 0)
        
        let signedAppController = SignedAppsViewController()
        signedAppController.title = "已签名"
        let signedAppNav = QMUINavigationController(rootViewController: signedAppController)
        signedAppNav.tabBarItem = UITabBarItem.init(title: "已签名", image: UIImage.init(named: "tabbar_app"), tag: 1)
        */
        
        let documentsController = DocumentsViewController()
        documentsController.title = "文件"
        documentsController.isRootViewController = true
        let documentsNav = QMUINavigationController(rootViewController: documentsController)
        documentsNav.tabBarItem = UITabBarItem.init(title: "文件", image: UIImage.init(named: "tabbar_file"), tag: 2)
                
//        let downloadController = DownloadViewController()
//        downloadController.title = "下载"
//        let downloadNav = QMUINavigationController(rootViewController: downloadController)
//        downloadNav.tabBarItem = UITabBarItem.init(title: "下载", image: UIImage.init(named: "tabbar_download"), tag: 3)
        
//        let settingViewController = SettingsViewController()
//        settingViewController.title = "设置"
//        let settingsNav = QMUINavigationController(rootViewController: settingViewController)
//        settingsNav.tabBarItem = UITabBarItem.init(title: "设置", image: UIImage.init(named: "tabbar_setting"), tag: 4)
        
        self.viewControllers = [documentsNav]
         
    }

}
