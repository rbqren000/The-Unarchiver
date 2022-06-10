//
//  TabBarViewController.swift
//  ABox
//
//  Created by YZL-SWING on 2020/11/16.
//

import UIKit
import Material

class TabBarViewController: QMUITabBarViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let documentsController = DocumentsViewController()
        documentsController.title = "文件"
        documentsController.isRootViewController = true
        let documentsNav = QMUINavigationController(rootViewController: documentsController)
        documentsNav.navigationBar.prefersLargeTitles = true
        documentsNav.navigationItem.largeTitleDisplayMode = .automatic
        documentsNav.tabBarItem = UITabBarItem.init(title: "文件", image: UIImage.init(named: "tabbar_folders"), tag: 2)
                
        let fileExchangeController = FileExchangeController()
        fileExchangeController.title = "互传"
        let fileExchangedNav = QMUINavigationController(rootViewController: fileExchangeController)
        fileExchangedNav.navigationBar.prefersLargeTitles = true
        fileExchangedNav.navigationItem.largeTitleDisplayMode = .automatic
        fileExchangedNav.tabBarItem = UITabBarItem.init(title: "互传", image: UIImage.init(named: "tabbar_exchange"), tag: 3)
        
        let downloadController = DownloadViewController()
        downloadController.title = "下载"
        let downloadNav = QMUINavigationController(rootViewController: downloadController)
        downloadNav.navigationBar.prefersLargeTitles = true
        downloadNav.navigationItem.largeTitleDisplayMode = .automatic
        downloadNav.tabBarItem = UITabBarItem.init(title: "下载", image: UIImage.init(named: "tabbar_download"), tag: 3)
        
        let settingViewController = SettingsViewController()
        settingViewController.title = "设置"
        let settingsNav = QMUINavigationController(rootViewController: settingViewController)
        settingsNav.tabBarItem = UITabBarItem.init(title: "设置", image: UIImage.init(named: "tabbar_settings"), tag: 4)
        settingsNav.navigationBar.prefersLargeTitles = true
        settingsNav.navigationItem.largeTitleDisplayMode = .automatic
        
        self.viewControllers = [documentsNav, fileExchangedNav, downloadNav, settingsNav]
        
    }

}
