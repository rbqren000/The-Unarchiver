//
//  WebDAVServerController.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/14.
//

import UIKit


class WebDAVServerSettings {
    var port: UInt = 8080
    var bonjourName: String = "The-Unarchiver"
}

class WebDAVServerController: ViewController {

    var dismissBlock: (() -> ())?

    var devServer: GCDWebDAVServer!
    let webDAVSettings = WebDAVServerSettings()
    let webDAVSwitch = UISwitch.init()
    
    private var tableView = QMUITableView.init(frame: .zero, style: .grouped)
    private let cellIdentifier = "WebDAVCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WebDAV Server"

        // Do any additional setup after loading the view.
        devServer = GCDWebDAVServer.init(uploadDirectory: FileManager.default.documentDirectory.path)
        devServer.delegate = self
    }

    override func initSubviews() {
        super.initSubviews()
        
        webDAVSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        if #available(iOS 13.0, *) {
            self.tableView = QMUITableView.init(frame: .zero, style: .insetGrouped)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(QMUITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.top.right.equalTo(0)
            maker.bottom.equalTo(0)
        }
    }
    override func setupNavigationItems() {
        super.setupNavigationItems()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "关闭", style: .done, target: self, action: #selector(dismissController))
    }
    
    @objc
    override func dismissController() {
        if devServer.isRunning {
            UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
            let alertController = QMUIAlertController.init(title: "是否关闭WebDAVServer？", message: nil, preferredStyle: .alert)
            alertController.addAction(QMUIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertController.addAction(QMUIAlertAction(title: "确定", style: .default, handler: { [unowned self] _, _ in
                self.devServer.stop()
                self.dismissBlock?()
                self.dismiss(animated: true, completion: nil)
            }))
            alertController.showWith(animated: true)
        } else {
            self.dismissBlock?()
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc
    func switchValueChanged(sender: UISwitch) {
        self.webDAVServer(isOn: sender.isOn)
    }

    func webDAVServer(isOn: Bool) {
        if devServer.isRunning {
            if isOn == false {
                devServer.stop()
            }
        } else {
            if isOn {
                let started = devServer.start(withPort: webDAVSettings.port, bonjourName: webDAVSettings.bonjourName)
                self.webDAVSwitch.isOn = started
                if started && devServer.serverURL != nil {
                    print(message: "Visit \(devServer.serverURL?.absoluteString) in your WebDAV client")
                } else {
                    webDAVSwitch.isOn = false
                    kAlert("暂时无法开启WebDAV，请稍后再试。")
                }
            }
        }
        
        self.tableView.reloadData()
    }
}

extension WebDAVServerController: QMUITableViewDelegate, QMUITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return devServer.isRunning && devServer.serverURL != nil ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if (cell == nil) {
            cell = QMUITableViewCell(for: tableView, with: .value1, reuseIdentifier: identifier)
            cell?.backgroundColor = .white
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.medium(aSize: 15)
            cell?.textLabel?.textColor = kTextColor
            cell?.detailTextLabel?.font = UIFont.regular(aSize: 14)
            cell?.detailTextLabel?.textColor = kSubtextColor
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.textLabel?.text = nil
        cell?.detailTextLabel?.text = nil
        cell?.accessoryType = .disclosureIndicator
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell?.textLabel?.text = "WebDAV Server"
                cell?.accessoryView = webDAVSwitch
            } else {
                cell?.textLabel?.text = "Port"
                cell?.detailTextLabel?.text = String.init(format: "%d", webDAVSettings.port)
                cell?.accessoryType = self.devServer.isRunning ? .none : .disclosureIndicator
            }
        } else {
            cell?.textLabel?.text = "URL"
            cell?.detailTextLabel?.text = devServer.serverURL?.absoluteString
            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 35, height: 35))
            imageView.image =  UIImage.init(named: "export")
            cell?.accessoryView = imageView
        }

        return cell!
    }
    
    

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 50 : 0.01
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? "开启WebDAV Server以便与在iOS、Mac或PC上访问" : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                if self.devServer.isRunning {
                    return
                }
                let alertController = QMUIAlertController.init(title: "设置WebDAVServer端口", message: nil, preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.keyboardType = .numberPad
                    textField.placeholder = "请输入端口"
                }
                alertController.addAction(QMUIAlertAction.init(title: "确定", style: .destructive, handler: { controller, action in
                    var portStr = ""
                    if let textField = controller.textFields?.first {
                        portStr = textField.text!
                    }
                    if let port: UInt = UInt(portStr) {
                        self.webDAVSettings.port = port
                        self.tableView.reloadData()
                    } else {
                        kAlert("请输入正确的端口，否则无法访问。")
                    }
                }))
                alertController.addCancelAction()
                alertController.showWith(animated: true)
            }
        } else if indexPath.section == 1 {
            if let serverURL = self.devServer.serverURL?.absoluteString {
                let activityVC = UIActivityViewController.init(activityItems: [serverURL], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }

}


extension WebDAVServerController: GCDWebDAVServerDelegate {
    
    func davServer(_ server: GCDWebDAVServer, didDeleteItemAtPath path: String) {
        print(message: "WebDAVServer didDeleteItemAtPath:\(path)")
    }
    
    func davServer(_ server: GCDWebDAVServer, didUploadFileAtPath path: String) {
        print(message: "WebDAVServer didUploadFileAtPath:\(path)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didDownloadFileAtPath path: String) {
        print(message: "WebDAVServer didDownloadFileAtPath:\(path)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didCreateDirectoryAtPath path: String) {
        print(message: "WebDAVServer didCreateDirectoryAtPath:\(path)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didCopyItemFromPath fromPath: String, toPath: String) {
        print(message: "WebDAVServer didCopyItemFromPath:\(fromPath) toPath:\(toPath)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didMoveItemFromPath fromPath: String, toPath: String) {
        print(message: "WebDAVServer didMoveItemFromPath:\(fromPath) toPath:\(toPath)")

    }
}
