//
//  DownloadViewController.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/10.
//

import UIKit
import Material

class DownloadViewController: ViewController {
    
    fileprivate let tableView = QMUITableView.init(frame: CGRect.zero, style: .grouped)
    fileprivate let cellIdentifier = "DownloadCell"
    fileprivate var tasks: [DownloadTask] = []
    fileprivate var downloadURLs: [String] = []
    fileprivate var addTaskButton = Button()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getHistoryDownloadList()
    }
    

    override func initSubviews() {
        super.initSubviews()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.setEmptyDataSet(title: nil, descriptionString: nil, image: UIImage(named: "file-storage"))
        self.tableView.register(DownloadTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.top.right.equalTo(0)
            maker.bottom.equalTo(0)
        }
        
        addTaskButton.frame = CGRect(x: kUIScreenWidth - 70, y: kUIScreenHeight - 170, width: 55, height: 55)
        addTaskButton.backgroundColor = kButtonColor
        addTaskButton.layer.cornerRadius = 27.5
        addTaskButton.setImage(Icon.add?.qmui_image(withTintColor: .white), for: .normal)
        addTaskButton.addTarget(self, action: #selector(dragMoving(control:event:)), for: .touchDragInside)
        addTaskButton.addTarget(self, action: #selector(dragEnded(control:event:)), for: .touchDragOutside)
        addTaskButton.addTarget(self, action: #selector(addTaskButtonTapped), for: .touchUpInside)
        self.view.addSubview(addTaskButton)
    }
    
    @objc
    func addTaskButtonTapped() {
        let alertController = QMUIAlertController.init(title: "选择下载方式", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(QMUIAlertAction.init(title: "从网络下载", style: .default, handler: { [unowned self] _, _ in
            self.showInputURLViewController(type: 0)
        }))
        alertController.addAction(QMUIAlertAction.init(title: "提取网页资源", style: .default, handler: { [unowned self] _, _ in
            self.showInputURLViewController(type: 1)
        }))
        alertController.addAction(QMUIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        alertController.showWith(animated: true)
    }
    
    func showInputURLViewController(type: Int) {
        let controller = InputURLViewController()
        controller.type = type
        let popupController = STPopupController(rootViewController: controller)
        popupController.style = .formSheet
        popupController.containerView.backgroundColor = .clear
        popupController.present(in: self)
        controller.completionWithURL = { [unowned self] url in
            if type == 0 {
                self.addTask(downloadURL: url)
            } else {
                self.addTaskFromWebController(url: url)
            }
        }
    }
    
    func addTaskFromWebController(url: URL) {
        let webVC = WebViewController(url: url)
        webVC.hidesBottomBarWhenPushed = true
        webVC.completionWithURL = { [unowned self] ipaURL in
            self.addTask(downloadURL: ipaURL)
        }
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    func addTask(downloadURL: URL) {
        if downloadURL.absoluteString.hasPrefix("itms-services") {
            self.downloadIPA(url: downloadURL)
        } else {
            if downloadURLs.contains(downloadURL.absoluteString) {
                kAlert("当前下载链接已存在")
                return
            }
            let task = DownloadTask()
            task.info.state = .downloading
            task.info.downloadURL = downloadURL.absoluteString
            task.info.createDate = Date().toString(.custom("yyyy-MM-dd HH:mm"))
            if downloadURL.pathExtension.lowercased().count > 0 {
                task.info.fileType = downloadURL.pathExtension.lowercased()
                if downloadURL.lastPathComponent.count > 1 {
                    task.info.fileName = downloadURL.lastPathComponent
                }
            }
            task.startDownload()
            self.downloadURLs.append(downloadURL.absoluteString)
            self.tasks.insert(task, at: 0)
            self.tableView.reloadData()
        }
    }
    
    func getHistoryDownloadList() {
        if let results: [YTKKeyValueItem] = Client.shared.store?.getAllItems(fromTable: kDownloadTableName) as? [YTKKeyValueItem] {
            for item in results {
                print(message: item)
                print(message: item.itemId)
                print(message: item.itemObject)
                if let array: [String] = item.itemObject as? [String] {
                    if array.count > 0 {
                        if let infoModel = DownloadTaskInfo.deserialize(from: array.first) {
                            let task = DownloadTask()
                            task.info = infoModel
                            if task.info.state == .finished {
                                if let fileName = task.info.fileName {
                                    let url = FileManager.default.downloadDirectory.appendingPathComponent(fileName)
                                    if FileManager.default.fileExists(atPath: url.path) == false {
                                        task.info.state = .deleted
                                    }
                                }
                            } else if task.info.state == .downloading || task.info.state == .paused {
                                task.info.state = .downloading
                                task.startDownload()
                            }
                            
                            downloadURLs.append(task.info.downloadURL)
                            tasks.append(task)
                        }
                    }
                }
            }
            tasks.sort { (d1, d2) -> Bool in
                return d1.info.createDate > d2.info.createDate
            }
            self.tableView.reloadData()
        }
    }
    
    @objc
    func dragMoving(control: UIControl, event: UIEvent) {
        if let center = event.allTouches?.first?.location(in: self.view) {
            control.center = center
        }
    }
    
    @objc
    func dragEnded(control: UIControl, event: UIEvent) {
        if let center = event.allTouches?.first?.location(in: self.view) {
            control.center = center
        }
    }
}

extension DownloadViewController: QMUITableViewDelegate, QMUITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: task.info.id) {
            return cell
        } else {
            let cell: DownloadTableViewCell = DownloadTableViewCell(for: tableView, withReuseIdentifier: task.info.id)
            cell.configCell(task)
            cell.openFileURLHandle = { [weak self] _ in
                let controller = DocumentsViewController()
                controller.indexFileURL = FileManager.default.downloadDirectory
                controller.title = "下载"
                controller.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let task = self.tasks[indexPath.row]
        let deleteAction = UITableViewRowAction.init(style: .destructive, title: "删除") { [weak self] _, i in
            Client.shared.store?.deleteObject(byId: task.info.id, fromTable: kDownloadTableName)
            self?.tasks.remove(at: indexPath.row)
            self?.tableView.reloadData()
        }
        deleteAction.backgroundColor = kRGBColor(243, 64, 54)
        return [deleteAction]
    }
}


extension DownloadViewController {
    
    func downloadIPA(url: URL) {
        if let plistURLStr = url.parametersFromQueryString?["url"] {
            DownloadManager.shared.download(urlStr: plistURLStr, request: nil) { fileURL in
                if let dict = NSDictionary(contentsOf: fileURL) {
                    if let arr: NSArray = dict["items"] as? NSArray {
                        if let item: NSDictionary = arr[0] as? NSDictionary {
                            do {
                                let data = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                                let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                if let json = json {
                                    if let assets = [Asset].deserialize(from: json as String, designatedPath: "assets") {
                                        for asset in assets {
                                            if let a = asset {
                                                if a.kind == "software-package" {
                                                    self.addTask(downloadURL: URL(string: a.url)!)
                                                }
                                            }
                                        }
                                    }
                                }
                            } catch let error {
                                kAlert(error.localizedDescription)
                            }
                        }
                    }
                }
            } failure: { error in
                kAlert(error)
            }
        }
    }
}
