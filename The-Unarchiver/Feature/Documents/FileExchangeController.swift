//
//  FileExchangeController.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/10.
//

import UIKit

class FileExchangeController: ViewController {
    
    var tableView = QMUITableView.init(frame: .zero, style: .grouped)
    private let cellIdentifier = "FileExchangeCell"

    override func initSubviews() {
        super.initSubviews()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func startWebUploader() {
        let controller = WebUploaderController()
        controller.dismissBlock = { [unowned self] in
            self.tableView.reloadData()
        }
        let nav = NavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func startWebDAV() {
        let controller = WebDAVServerController()
        controller.dismissBlock = { [unowned self] in
            self.tableView.reloadData()
        }
        let nav = NavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension FileExchangeController: QMUITableViewDelegate, QMUITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            cell?.detailTextLabel?.font = UIFont.regular(aSize: 12)
            cell?.detailTextLabel?.textColor = kSubtextColor
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.imageView?.image = nil
        cell?.textLabel?.text = nil
        cell?.detailTextLabel?.text = nil
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = "WiFi传输"
            cell?.imageView?.image = UIImage.init(named: "wifi-signal")?.resize(toWidth: 35)
            if let webUploader = Client.shared.webUploader {
                if webUploader.isRunning && webUploader.serverURL != nil {
                    cell?.detailTextLabel?.text = webUploader.serverURL?.absoluteString
                }
            }
        } else {
            cell?.textLabel?.text = "WebDAV"
            cell?.imageView?.image = UIImage.init(named: "webdav")?.resize(toWidth: 35)
            if let davServer = Client.shared.davServer {
                if davServer.isRunning && davServer.serverURL != nil {
                    cell?.detailTextLabel?.text = davServer.serverURL?.absoluteString
                }
            }
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "与电脑互传文件" : "WebDAV Server"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            startWebUploader()
        } else {
            startWebDAV()
        }
    }

}
