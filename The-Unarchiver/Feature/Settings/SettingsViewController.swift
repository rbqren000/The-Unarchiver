//
//  SettingViewController.swift
//  ABox
//
//  Created by YZL-SWING on 2020/11/17.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SafariServices
import Async

class SettingsViewController: ViewController {
    
    var tableView = QMUITableView.init(frame: CGRect.zero, style: .grouped)
    var cacheSize: Int = 0
    let cellIdentifier = "settingsCell"
    let privateURL = URL(string: "https://abox.swing1993.cn/privacycn.html")!
    let aboxGitHubURL = URL(string: "https://github.com/SWING1993/ABox_iOS")!
    let aboxIssuesURL = URL(string: "https://github.com/SWING1993/ABox_iOS/issues")!

    //  ("关于我们", "ic_aboutus")
    let cellData = [[("解压设置", "", "rar-setting")],
                    [//("问题反馈", "", "feedback"),
                     //("分享给好友", "", "ic_share"),
                     ("清理缓存", "", "ic_helper"),
                     ("服务及隐私协议", "", "ic_unlock"),
                     ("Licenses", "Libraries", "license"),
                     //("GitHub仓库", "", "github-logo"),
                     ("关于我们", "", "ic_aboutus")]]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        Async.background {
            self.cacheSize = self.fileSizeOfCache()
            Async.main {
                self.tableView.reloadData()
            }
        }
    }
    
    override func setupNavigationItems() {
        super.setupNavigationItems()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func initSubviews() {
        super.initSubviews()
        if #available(iOS 13.0, *) {
            self.tableView = QMUITableView.init(frame: .zero, style: .insetGrouped)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(QMUITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.top.right.equalTo(0)
            maker.bottom.equalTo(0)
        }
    }
    
  
}


extension SettingsViewController: QMUITableViewDelegate, QMUITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellData[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = QMUITableViewCell(for: tableView, with: .value1, reuseIdentifier: identifier)
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.medium(aSize: 14)
            cell?.textLabel?.textColor = kTextColor
            cell?.detailTextLabel?.font = UIFont.regular(aSize: 12)
            cell?.detailTextLabel?.textColor = kSubtextColor
        }
        
        cell?.accessoryType = .disclosureIndicator
        let item = self.cellData[indexPath.section][indexPath.row]
        cell?.textLabel?.text = item.0
        cell?.detailTextLabel?.text = item.1
        cell?.imageView?.image = UIImage(named: item.2)?.qmui_image(withTintColor: kTextColor)
        if item.0 == "清理缓存" {
            cell?.detailTextLabel?.text = String.fileSizeDesc(self.cacheSize)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0.01 : 30
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? nil : "\(kAppDisPlayName!)：\(kAppVersion!)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.cellData[indexPath.section][indexPath.row]
        if item.0 == "分享给好友" {
            let title = kAppDisPlayName!
            let image = UIImage(named: "icon-1024")!
            let items: [Any] = [aboxGitHubURL, title, image]
            let activityVC = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        } else if item.0 == "清理缓存" {
            QMUITips.showLoading("正在清理缓存...", in: self.view).whiteStyle()
            Async.background {
                let result = self.clearCache()
                if result {
                    Async.main {
                        self.cacheSize = 0
                        self.tableView.reloadData()
                        QMUITips.hideAllTips(in: self.view)
                        QMUITips.showSucceed("已清除全部缓存", in: self.view).whiteStyle()
                    }
                }
            }
        } else if item.0 == "问题反馈" {
            UIApplication.shared.open(aboxIssuesURL, options: [:]) { completion in
                
            }
        } else if item.0 == "服务及隐私协议" {
            self.openURLWithSafari(privateURL)
        } else if item.0 == "关于我们" {
            let controller = AboutUSViewController()
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        } else if item.0 == "GitHub仓库" {
            UIApplication.shared.open(aboxGitHubURL, options: [:]) { completion in
                
            }
        } else if item.0 == "Licenses" {
            let controller = LicensesViewController()
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    


}

extension SettingsViewController {

    func fileSizeOfCache()-> Int {
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        //缓存目录路径
        print(cachePath)
        // 取出文件夹下所有文件数组
        //快速枚举出所有文件名 计算文件大小
        var size = 0
        if let fileArr = FileManager.default.subpaths(atPath: cachePath.path) {
            for file in fileArr {
                // 把文件名拼接到路径中
                let path = cachePath.appendingPathComponent(file).path
                // 取出文件属性
                let floder = try! FileManager.default.attributesOfItem(atPath: path)
                // 用元组取出文件大小属性
                for (abc, bcd) in floder {
                    // 累加文件大小
                    if abc == FileAttributeKey.size {
                        size += (bcd as AnyObject).integerValue
                    }
                }
            }
        }
        return size
    }
    
    func clearCache() -> Bool {
        URLCache.shared.removeAllCachedResponses()
        do {
            try FileManager.default.removeItem(atPath: FileManager.default.cacheDirectory.path)
        } catch let error {
            print(message: "清理失败，\(error.localizedDescription)")
        }
        return true
    }
}

struct SettingsCellData {
    var title = ""
    var icon = ""
}
