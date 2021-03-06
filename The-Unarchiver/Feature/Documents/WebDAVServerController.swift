//
//  WebDAVServerController.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/14.
//

import UIKit
import CoreLocation

class WebDAVServerSettings {
    var port: UInt = 8081
    var bonjourName: String = "The-Unarchiver"
}

class WebDAVServerController: ViewController {

    var dismissBlock: (() -> ())?
    let webDAVSettings = WebDAVServerSettings()
    let webDAVSwitch = UISwitch()
    
    private var tableView = QMUITableView.init(frame: .zero, style: .grouped)
    private let cellIdentifier = "WebDAVCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WebDAV Server"
        // Do any additional setup after loading the view.
        configWebDAVServerSettings()
        if let davServer = Client.shared.davServer {
            webDAVSwitch.isOn = davServer.isRunning && davServer.serverURL != nil
        }
        self.tableView.reloadData()
        print(message: CLLocationManager.authorizationStatus())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func configWebDAVServerSettings() {
        if let port: Int = AppDefaults.shared.webDAVPort {
            if port > 0 {
                self.webDAVSettings.port = UInt(port)
            }
        }

    }

    override func initSubviews() {
        super.initSubviews()
        
        webDAVSwitch.addTarget(self, action: #selector(webDAVServer(sender:)), for: .valueChanged)
        
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "??????", style: .done, target: self, action: #selector(dismissController))
    }
    
    @objc
    override func dismissController() {
        self.dismissBlock?()
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    func webDAVServer(sender: UISwitch) {
        let isOn = sender.isOn
        Client.shared.webDAVServer(start: isOn, port: webDAVSettings.port)
        if let davServer = Client.shared.davServer {
            webDAVSwitch.isOn = davServer.isRunning && davServer.serverURL != nil
        }
        self.tableView.reloadData()
    }
}

extension WebDAVServerController: QMUITableViewDelegate, QMUITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return webDAVSwitch.isOn ? 2 : 1
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
            } else if indexPath.row == 1 {
                cell?.textLabel?.text = "Port"
                cell?.detailTextLabel?.text = String.init(format: "%d", webDAVSettings.port)
                cell?.accessoryType = webDAVSwitch.isOn ? .none : .disclosureIndicator
            }
        } else if indexPath.section == 1 {
            cell?.textLabel?.text = "URL"
            cell?.detailTextLabel?.text = Client.shared.davServer?.serverURL?.absoluteString
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
        return section == 0 ? "??????WebDAV Server????????????iOS???Mac???PC?????????" : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                if webDAVSwitch.isOn {
                    return
                }
                let alertController = QMUIAlertController.init(title: "??????WebDAVServer??????", message: nil, preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.keyboardType = .numberPad
                    textField.placeholder = "???????????????"
                    textField.text = "\(self.webDAVSettings.port)"
                }
                alertController.addAction(QMUIAlertAction.init(title: "??????", style: .destructive, handler: { controller, action in
                    var portStr = ""
                    if let textField = controller.textFields?.first {
                        portStr = textField.text!
                    }
                    if let port: UInt = UInt(portStr) {
                        self.webDAVSettings.port = port
                        AppDefaults.shared.webDAVPort = Int(port)
                        self.tableView.reloadData()
                    } else {
                        kAlert("????????????????????????????????????????????????")
                    }
                }))
                alertController.addCancelAction()
                alertController.showWith(animated: true)
            }
        } else if indexPath.section == 1 {
            if let serverURL = Client.shared.davServer?.serverURL?.absoluteString {
                let activityVC = UIActivityViewController.init(activityItems: [serverURL], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }

}


