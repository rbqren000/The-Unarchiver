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
    
    let tableView = QMUITableView.init(frame: CGRect.zero, style: .grouped)
    let cellIdentifier = "settingsCell"
    let privateURL = URL(string: "https://abox.swing1993.cn/private.html")!
    let tutorialURL = URL(string: "https://swing1993.cn/aboxshi-yong-jiao-cheng/")!
    let aboxReleaseURL = URL(string: "https://github.com/SWING1993/ABox_iOS/releases")!
    let aboxGitHubURL = URL(string: "https://github.com/SWING1993/ABox_iOS")!
    let aboxIssuesURL = URL(string: "https://github.com/SWING1993/ABox_iOS/issues")!

    //  ("关于我们", "ic_aboutus")
    let cellData = [[("证书管理", "ic_contract"),
                     ("设备UDID", "ic_udid"),
                     ("解锁码有效期", "ic_lock")],
                    [("检测更新", "ic_update"),
                     ("问题反馈", "feedback"),
                     //                     ("分享给好友", "ic_share"),
                     ("清理缓存", "ic_helper"),
                     ("使用教程", "ic_aboutus"),
                     ("服务及隐私协议", "ic_unlock"),
                     ("GitHub仓库", "github-logo")]]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func setupNavigationItems() {
        super.setupNavigationItems()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initSubviews() {
        super.initSubviews()

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
            cell?.detailTextLabel?.font = UIFont.regular(aSize: 13)
            cell?.detailTextLabel?.textColor = kTextColor
        }
        
        cell?.accessoryType = .disclosureIndicator
        let item = self.cellData[indexPath.section][indexPath.row]
        cell?.textLabel?.text = item.0
        cell?.imageView?.image = UIImage(named: item.1)?.qmui_image(withTintColor: kTextColor)
        cell?.detailTextLabel?.text = nil

        if item.0 == "证书管理" {
            if let signingCertificateName = AppDefaults.shared.signingCertificateName {
                cell?.detailTextLabel?.text = signingCertificateName
            } else {
                cell?.detailTextLabel?.text = "选择签名证书"
            }
           
        } else if item.0 == "设备UDID" {
            if let udid = AppDefaults.shared.deviceUDID {
                cell?.detailTextLabel?.text = udid
            } else {
                cell?.detailTextLabel?.text = "点击获取"
            }
        } else if item.0 == "解锁码有效期" {
            cell?.detailTextLabel?.text = "点击解锁"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0.01 : 60
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? nil : "\(kAppDisPlayName!)：\(kAppVersion!)(\(kAppBuildVersion!))\nAppID：\(kAppBundleIdentifier!)\n编译日期：\(NSString.bulidDate())"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let item = self.cellData[indexPath.section][indexPath.row]
        if item.0 == "证书管理" {
            let controller = CertificateListViewController()
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        } else if item.0 == "分享给好友" {
            let title = kAppDisPlayName!
            let image = UIImage(named: "icon-1024")!
            let items: [Any] = [aboxGitHubURL, title, image]
            let activityVC = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        } else if item.0 == "清理缓存" {
            QMUITips.showLoading("清理中...", in: self.view).whiteStyle()
            Async.background {
                self.clearCache()
            } .main {
                self.tableView.reloadData()
                QMUITips.hideAllTips(in: self.view)
                kAlert("已清除全部缓存")
            }
        } else if item.0 == "检测更新" {
            UIApplication.shared.open(aboxReleaseURL, options: [:]) { completion in
                
            }
        } else if item.0 == "问题反馈" {
            UIApplication.shared.open(aboxIssuesURL, options: [:]) { completion in
                
            }
        } else if item.0 == "服务及隐私协议" {
            let webVC = WebViewController(url: privateURL)
            webVC.hidesBottomBarWhenPushed = true
            webVC.title = "隐私协议"
            self.navigationController?.pushViewController(webVC, animated: true)
        } else if item.0 == "关于我们" {
            let controller = AboutUSViewController()
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        } else if item.0 == "设备UDID" {
            let alertController = QMUIAlertController.init(title: "获取UDID", message: "下载配置描述文件后请在【设置】应用中安装。", preferredStyle: .actionSheet)
            if let udid = AppDefaults.shared.deviceUDID {
                alertController.addAction(QMUIAlertAction.init(title: "复制", style: .default, handler: { _, _ in
                    UIPasteboard.general.string = udid
                    QMUITips.showSucceed("已复制UDID\n\(udid)", in: self.view).whiteStyle()
                }))
                alertController.addAction(QMUIAlertAction.init(title: "重新获取", style: .destructive, handler: { _, _ in
                    self.getUDID()
                }))
            } else {
                alertController.addAction(QMUIAlertAction.init(title: "获取", style: .destructive, handler: { _, _ in
                    self.getUDID()
                }))
            }
            alertController.addAction(QMUIAlertAction.init(title: "取消", style: .cancel, handler: nil))
            alertController.showWith(animated: true)
        } else if item.0 == "使用教程" {
            let webVC = WebViewController(url: tutorialURL)
            webVC.hidesBottomBarWhenPushed = true
            webVC.title = "使用教程"
            self.navigationController?.pushViewController(webVC, animated: true)
        } else if item.0 == "解锁码有效期" {
            if Client.shared.device.vipType <= 0 {
                let alert = QMUIAlertController.init(title: "解锁码", message: nil, preferredStyle: .actionSheet)
                alert.addAction(QMUIAlertAction.init(title: "输入解锁码", style: .default, handler: { _, _ in
                    self.showActivateVipDialogViewController()
                }))
                alert.addAction(QMUIAlertAction.init(title: "购买", style: .default, handler: { _, _ in
                    self.openURLWithSafari(KuaifakaURL)
                }))
                alert.addAction(QMUIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                alert.showWith(animated: true)
            }
        } else if item.0 == "GitHub仓库" {
            UIApplication.shared.open(aboxGitHubURL, options: [:]) { completion in
                
            }
        }
         */
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
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        // 取出文件夹下所有文件数组
        if let fileArr = FileManager.default.subpaths(atPath: cacheURL.path) {
            // 遍历删除
            for file in fileArr {
                let path = cacheURL.appendingPathComponent(file).path
                do {
                    try FileManager.default.removeItem(atPath: path)
                    print(message: "清理\(path)")
                } catch let error {
                    print(message: "清理\(path)失败，\(error.localizedDescription)")
                }
            }
        }
    }
}

struct SettingsCellData {
    var title = ""
    var icon = ""
}
