//
//  DocumentsViewController.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/10.
//

import UIKit
import QuickLook
import Material
import Async

class DocumentsViewController: ViewController {
    
    public var indexFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    public var isRootViewController = false
    public var selectFileCallback: ((File) -> ())?
    
    private let tableView = QMUITableView.init(frame: CGRect.zero, style: .grouped)
    private var segmentIndex = 0
    private var segmentedControl: UISegmentedControl!
    private var filesDescLabel = UILabel()
    private let cellIdentifier = "fileCell"
    private var files: [File] = []
    private var recycleBinFile = File()
    private var previewItem: QLPreviewItem?
    private var flag = false
    private let menuPopupView = QMUIPopupMenuView()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(message: indexFileURL)
        self.tableView.isHidden = true
        self.showEmptyViewWithLoading()
        getFolderFiles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if flag {
            getFolderFiles()
        }
        flag = true
    }
    
    override func setupNavigationItems() {
        super.setupNavigationItems()
    }
    
    override func initSubviews() {
        super.initSubviews()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.setEmptyDataSet(title: nil, descriptionString: nil, image: UIImage(named: "file-storage"))
        self.tableView.register(QMUITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.top.right.equalTo(0)
            maker.bottom.equalTo(0)
        }
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kUIScreenWidth, height: 45))
        tableView.tableHeaderView = tableHeaderView
        
        self.segmentedControl = UISegmentedControl.init(items: ["类型", "名称", "大小", "修改时间"])
        self.segmentedControl.frame = CGRect(x: 15, y: 7.5, width: kUIScreenWidth - 75, height: 30)
        self.segmentedControl.selectedSegmentIndex = segmentIndex
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlChange(sender:)), for: .valueChanged)
        tableHeaderView.addSubview(self.segmentedControl)
        
        filesDescLabel.frame =  CGRect(x: kUIScreenWidth - 75, y: 7.5, width: 60, height: 30)
        filesDescLabel.font = UIFont.regular(aSize: 14)
        filesDescLabel.textColor = kSubtextColor
        filesDescLabel.textAlignment = .right
        filesDescLabel.adjustsFontSizeToFitWidth = true
        tableHeaderView.addSubview(self.filesDescLabel)
                
        
        let menuButton = UIBarButtonItem.init(image: UIImage(named: "more-information"), style: .done, target: self, action: #selector(menuButtonTapped))
        self.navigationItem.rightBarButtonItem = menuButton
        
        self.menuPopupView.automaticallyHidesWhenUserTap = true
        self.menuPopupView.shouldShowItemSeparator = true
        self.menuPopupView.tintColor = .black
        self.menuPopupView.itemConfigurationHandler = { aMenuView, aItem, section, index in
            if let item = aItem as? QMUIPopupMenuButtonItem {
                item.button.setTitleColor(.black, for: .normal)
            }
        }
        
        let importFilePopupItem = QMUIPopupMenuButtonItem.init(image: UIImage.init(named: "icon_import"), title: "导入文件") {[unowned self] _ in
            self.menuPopupView.hideWith(animated: true)
            self.importFile()
        }
        let createFolderPopupItem = QMUIPopupMenuButtonItem.init(image: UIImage.init(named: "icon_add_folder"), title: "新建文件夹") { [unowned self] _ in
            self.menuPopupView.hideWith(animated: true)
            self.createFolder()
        }
    
        self.menuPopupView.items = [importFilePopupItem, createFolderPopupItem]
        self.menuPopupView.sourceBarItem = menuButton
        
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
    
    @objc
    func menuButtonTapped() {
        self.menuPopupView.showWith(animated: true)
    }
}


extension DocumentsViewController: QMUITableViewDelegate, QMUITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isRootViewController ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.files.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if (cell == nil) {
            cell = QMUITableViewCell(for: tableView, with: .subtitle, reuseIdentifier: identifier)
            cell?.backgroundColor = .white
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.medium(aSize: 14)
            cell?.textLabel?.textColor = kTextColor
            cell?.detailTextLabel?.font = UIFont.regular(aSize: 12)
            cell?.detailTextLabel?.textColor = kSubtextColor
        }
        if indexPath.section == 0 {
            let file = files[indexPath.row]
            if file.isAppBundle {
                let application = TUApplication.init(fileURL: file.url)!
                cell?.imageView?.image = application.icon?.resize(toWidth: 40)?.qmui_image(withClippedCornerRadius: 10)
                cell?.textLabel?.text = "\(application.name) - v\(application.version)"
                cell?.detailTextLabel?.text = "\(file.name) - \(application.bundleIdentifier)"
                cell?.accessoryType = .disclosureIndicator
            } else {
                cell?.textLabel?.text = file.name
                if file.isFolder {
                    cell?.imageView?.image = UIImage(named: "file_ext_folder")
                    cell?.detailTextLabel?.text = "\(String.timeStr(file.modificationDate))"
                    cell?.accessoryType = .disclosureIndicator
                } else {
                    cell?.accessoryType = .none
                    cell?.imageView?.image = file.getFileThumbnails()
                    cell?.detailTextLabel?.text = "\(String.timeStr(file.modificationDate)) - \(file.sizeDesc)"
                }
            }
        } else {
            cell?.textLabel?.text = "回收站"
            cell?.imageView?.image = UIImage(named: "file_bin")
            cell?.detailTextLabel?.text = String.timeStr(recycleBinFile.modificationDate)
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let file = files[indexPath.row]
            if self.selectFileCallback != nil && !file.isFolder {
                self.selectFileCallback?(file)
                self.dismissController()
            } else {
                openFile(file)
            }
        } else {
            let controller = DocumentsViewController()
            controller.indexFileURL = recycleBinFile.url
            controller.title = "回收站"
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
       
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let file = self.files[indexPath.row]
            let moveAction = UITableViewRowAction.init(style: .default, title: "移动") { [unowned self] _, i in
                UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                self.moveFile(file)
            }
            moveAction.backgroundColor = kRGBColor(250, 188, 4)
            
            let renameAction = UITableViewRowAction.init(style: .default, title: "重命名") { [unowned self] _, i in
                UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                //            let fileName = file.name
                let dialogViewController = QMUIDialogTextFieldViewController()
                dialogViewController.title = "重命名"
                dialogViewController.addTextField(withTitle: nil) { (titleLabel, textField, separatorLayer) in
                    textField.placeholder = file.name
                    textField.text = file.name
                    textField.maximumTextLength = 100
                }
                dialogViewController.shouldManageTextFieldsReturnEventAutomatically = true
                dialogViewController.addCancelButton(withText: "取消", block: nil)
                dialogViewController.addSubmitButton(withText: "确定") { [unowned self] d in
                    d.hide()
                    let text = dialogViewController.textFields![0].text!
                    if text != file.name {
                        self.renameFile(file, name: text)
                    }
                }
                dialogViewController.show()
            }
            renameAction.backgroundColor = kRGBColor(80, 168, 80)
            
            let deleteAction = UITableViewRowAction.init(style: .destructive, title: "删除") { [unowned self] _, i in
                UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                self.deleteFile(file, index: i.row)
            }
            deleteAction.backgroundColor = kRGBColor(243, 64, 54)
            
            if file.isFolder == false {
                let shareAction = UITableViewRowAction.init(style: .default, title: "分享") { [unowned self] _, i in
                    UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                    self.shareFile(file)
                }
                shareAction.backgroundColor = kButtonColor
                return [deleteAction, shareAction, moveAction, renameAction]
            }
            return [deleteAction, moveAction, renameAction]
        } else {
            let deleteAction = UITableViewRowAction.init(style: .destructive, title: "清空") { [unowned self] _, i in
                UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                QMUITips.showLoading(in: self.view).whiteStyle()
                Async.background {
                    do {
                        try FileManager.default.removeItem(at: self.recycleBinFile.url)
                        try FileManager.default.createDirectory(at: self.recycleBinFile.url, withIntermediateDirectories: true)
                    } catch let error {
                        print(message: error.localizedDescription)
                    }
                } .main {
                    QMUITips.hideAllTips()
                    self.recycleBinFile = File.init(fileURL: FileManager.default.recycleBinDirectory)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
          
            }
            deleteAction.backgroundColor = kRGBColor(243, 64, 54)
            return [deleteAction]
        }
    }
}

extension DocumentsViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem!
    }
}

extension DocumentsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == .import {
            if FileManager.default.fileExists(atPath: FileManager.default.importFileDirectory.path) == false {
                do {
                    try FileManager.default.createDirectory(atPath: FileManager.default.importFileDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    kAlert(error.localizedDescription)
                }
            }
            for url in urls {
                let fileName = url.lastPathComponent
                let savePath = FileManager.default.importFileDirectory.appendingPathComponent(fileName).path
                do {
                    try FileManager.default.createFile(atPath: savePath, contents: Data(contentsOf: url), attributes: nil)
                    self.getFolderFiles()
                } catch {
                    kAlert("\(fileName)导入失败")
                }
            }
        }
    }
}

extension DocumentsViewController {
    
    @objc
    func segmentedControlChange(sender: UISegmentedControl) {
        self.segmentIndex = sender.selectedSegmentIndex
        self.reloadTableData()
    }
    
    func reloadTableData() {
        //["类型", "名称", "大小", "修改时间"]
        if self.files.count > 1 {
            self.files.sort { (f1, f2) -> Bool in
                if self.segmentIndex == 0 {
                    if f1.isFolder && f2.isFolder {
                        if f1.isAppBundle {
                            return true
                        }
                        return f1.name < f2.name
                    }
                    return f1.type < f2.type
                } else if self.segmentIndex == 1 {
                    return f1.name < f2.name
                }  else if self.segmentIndex == 2 {
                    return f1.size > f2.size
                } else {
                    if let d1 = f1.modificationDate {
                        if let d2 = f2.modificationDate {
                            return d1 > d2
                        }
                    }
                    return f1.name > f2.name
                }
            }
        }
        filesDescLabel.text = "\(self.files.count)项"
        tableView.reloadData()
    }
}

extension DocumentsViewController {
    
    func importImages() {
        let imagePickerVC = TZImagePickerController(maxImagesCount: 20, delegate: nil)!
        imagePickerVC.naviTitleColor = .black
        imagePickerVC.barItemTextColor = .black
        imagePickerVC.allowPickingGif = false
        self.present(imagePickerVC, animated: true, completion: nil)
        imagePickerVC.didFinishPickingPhotosHandle = { [unowned self] photos, assets, isSelectOriginalPhoto in
            if let assets: [PHAsset] = assets as? [PHAsset] {
                self.savePHAssets(assets)
            }
        }
        imagePickerVC.didFinishPickingVideoHandle = { [unowned self] coverImage, asset in
            if let asset = asset {
                self.savePHAssets([asset], type: .video)
            }
        }
    }
    
    func savePHAssets(_ assets: [PHAsset], type: PHAssetResourceType = .photo) {
        let importAssetsURL = FileManager.default.importFileDirectory
        if FileManager.default.fileExists(atPath: importAssetsURL.path) == false {
            do {
                try FileManager.default.createDirectory(atPath: importAssetsURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print(message: error.localizedDescription)
            }
        }
        for asset in assets {
            for resource in PHAssetResource.assetResources(for: asset) {
                if resource.type == type {
                    if let assetURL: URL = resource.value(forKey: "privateFileURL") as? URL {
                        print(message: "assetURL:\(assetURL.absoluteString)")
                        let savePath = importAssetsURL.appendingPathComponent(resource.originalFilename).path
                        do {
                            try FileManager.default.createFile(atPath: savePath, contents: Data(contentsOf: assetURL), attributes: nil)
                            kAlert("\(resource.originalFilename)导入成功")
                        } catch {
                            kAlert("\(resource.originalFilename)导入失败")
                        }
                    }
                }
            }
        }
        self.getFolderFiles()
        print(message: "刷新数据")
    }
    
    @objc
    func importFile() {
        let controller = ImportViewController()
        let popupController = STPopupController(rootViewController: controller)
        popupController.style = .formSheet
        popupController.containerView.backgroundColor = .clear
        popupController.present(in: self)
        controller.completionWithTapIndex = { [unowned self] index in
            if index == 0 {
                self.importImages()
            } else if index == 1 {
                self.importFileWithDocumentController()
            } else {
                self.startWebUploader()
            }
        }
    }
    
    func importFileWithDocumentController() {
        let documentTypes = ["public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"];
        let documentPickerController = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    @objc
    func startWebUploader() {
        let controller = WebUploaderController()
        controller.dismissBlock = { [unowned self] in
            self.getFolderFiles()
        }
        let nav = NavigationController(rootViewController: controller)
        self.present(nav, animated: true, completion: nil)
    }
    

    @objc
    func getFolderFiles() {
        Async.background {
            if self.isRootViewController {
                if !FileManager.default.fileExists(atPath: FileManager.default.recycleBinDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: FileManager.default.recycleBinDirectory, withIntermediateDirectories: true)
                    } catch let error {
                        print(message: error.localizedDescription)
                    }
                }
                self.recycleBinFile = File.init(fileURL: FileManager.default.recycleBinDirectory)
            }
            do {
                let dirArray = try FileManager.default.contentsOfDirectory(atPath: self.indexFileURL.path)
                self.files.removeAll()
                for name in dirArray {
                    if name.hasPrefix(".") {
                        continue
                    }
                    let subPath: URL = self.indexFileURL.appendingPathComponent(name)
                    let file = File.init(fileURL: subPath)
                    FileManager.default.setFilePosixPermissions(file.url)
                    self.files.append(file)
                }
                self.files.sort { (file1, file2) -> Bool in
                    if let date1 = file1.modificationDate {
                        if let date2 = file2.modificationDate {
                            return date1 > date2
                        }
                    }
                    return false
                }
                Async.main {
                }
            } catch let error {
                self.files.removeAll()
                print(message: error.localizedDescription)
            }
            Async.main {
                self.tableView.isHidden = false
                self.hideEmptyView()
                self.reloadTableData()

            }
        }

    }
    
    func quickLook(url: URL) {
        QMUITips.showLoading(in: self.view).whiteStyle()
        self.previewItem = url as QLPreviewItem
        let qlPreviewController = QLPreviewController.init()
        qlPreviewController.modalPresentationStyle = .formSheet
        qlPreviewController.delegate = self ;
        qlPreviewController.dataSource = self ;
        qlPreviewController.reloadData()
        qlPreviewController.refreshCurrentPreviewItem()
        qlPreviewController.currentPreviewItemIndex = 0
        self.present(qlPreviewController, animated: true) {
            QMUITips.hideAllTips()
        }
    }
    
    func openFile(_ file: File) {
        if file.isArchiver {
            UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
            let xadHelper = XADHelper()
            let encrypted = xadHelper.archiverIsEncrypted(withPath: file.url.path)
            let alertController = QMUIAlertController.init(title: "是否解压该文件？", message: file.url.lastPathComponent, preferredStyle: .alert)
            if encrypted {
                alertController.addTextField { textField in
                    textField.keyboardType = .asciiCapable
                    textField.placeholder = "请输入解压密码"
                    textField.isSecureTextEntry = true
                }
            }
            alertController.addAction(QMUIAlertAction.init(title: "确定", style: .destructive, handler: { controller, action in
                var password = ""
                if encrypted {
                    if let textField = controller.textFields?.first {
                        password = textField.text!
                    }
                    if encrypted && password.count <= 0 {
                        kAlert("请输入解压密码")
                        UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                        return
                    }
                }
                if file.isZip && password.count <= 0 {
                    self.unZip(file)
                } else {
                    self.unArchiver(file, password: password)
                }
            }))
            alertController.addCancelAction()
            alertController.showWith(animated: true)
        } else if file.isAppBundle {
            UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
            let alertController = QMUIAlertController.init(title: file.url.lastPathComponent, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(QMUIAlertAction.init(title: "打包IPA", style: .destructive, handler: { _, _ in
                QMUITips.showLoading("正在打包IPA...", detailText: file.name, in: self.view).whiteStyle()
                Async.background {
                    do {
                        try FileManager.default.zipAppBundle(at: file.url)
                        Async.main {
                            QMUITips.hideAllTips()
                            self.getFolderFiles()
                        }
                    } catch let error {
                        Async.main {
                            QMUITips.hideAllTips()
                            kAlert(error.localizedDescription)
                        }
                    }
                }
            }))
            alertController.addAction(QMUIAlertAction.init(title: "查看文件", style: .default, handler: { _, _ in
                let controller = DocumentsViewController()
                controller.indexFileURL = file.url
                controller.selectFileCallback = self.selectFileCallback
                controller.title = file.name
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            alertController.addCancelAction()
            alertController.showWith(animated: true)
        } else if file.isFolder {
            let controller = DocumentsViewController()
            controller.selectFileCallback = self.selectFileCallback
            controller.indexFileURL = file.url
            controller.title = file.name
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        } else if file.isIPA {
            UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
            let alertController = QMUIAlertController.init(title: file.name, message: "安装期间请不要退出对话框，否则可能会导致安装失败。", preferredStyle: .actionSheet)
            alertController.addAction(QMUIAlertAction.init(title: "解压", style: .default, handler: { _, _ in
                self.unZip(file)
            }))
            
            alertController.addAction(QMUIAlertAction.init(title: "安装", style: .destructive, handler: { _, _ in
                AppManager.default.requestFile(file.url)
            }))

            alertController.addAction(QMUIAlertAction.init(title: "取消", style: .cancel, handler: nil))
            alertController.showWith(animated: true)
        } else if file.isPlist {
            if let dictionary = NSMutableDictionary.init(contentsOf: file.url) {
                let controller = PlistPreviewController.init(dictionary: dictionary)
                controller.plistURL = file.url
                controller.title = file.name
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.quickLook(url: file.url)
            }
        } else {
            self.quickLook(url: file.url)
        }
    }
    
    func deleteFile(_ file: File, index: Int) {
        UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
        let alertController = QMUIAlertController.init(title: "确定删除\(file.name)吗？", message: nil, preferredStyle: .alert)
        alertController.addAction(QMUIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(QMUIAlertAction(title: "确定", style: .default, handler: { [unowned self] _, _ in
            QMUITips.showLoading(in: self.view).whiteStyle()
            /// 移动到回收站
            do {
                if self.indexFileURL.path == FileManager.default.recycleBinDirectory.path {
                    try FileManager.default.removeItem(at: file.url)
                } else {
                    let moveURL = FileManager.default.recycleBinDirectory.appendingPathComponent(file.name)
                    if FileManager.default.fileExists(atPath: moveURL.path) {
                        try FileManager.default.removeItem(at: moveURL)
                    }
                    try FileManager.default.moveItem(at: file.url, to: moveURL)
                }
                self.files.remove(at: index)
                self.recycleBinFile = File(fileURL: FileManager.default.recycleBinDirectory)
                self.tableView.reloadData()
                QMUITips.hideAllTips()
            } catch let error {
                kAlert(error.localizedDescription)
                QMUITips.hideAllTips()
            }
 
        }))
        alertController.showWith(animated: true)
    }
    
    func shareFile(_ file: File) {
        let activityVC = UIActivityViewController(activityItems: [file.url], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func renameFile(_ file: File, name: String) {
        let newPath = file.url.path.replacingOccurrences(of: file.url.lastPathComponent, with: "")
        let moveToPath = newPath + name
        let moveURL = URL(fileURLWithPath: moveToPath)
        do {
            try FileManager.default.moveItem(at: file.url, to:moveURL)
            self.getFolderFiles()
            QMUITips.showSucceed("修改成功", in: self.view).whiteStyle()
        } catch let error {
            print(message: error.localizedDescription)
        }
    }
    
    func moveFile(_ file: File) {
        let controller = MoveFolderViewController()
        controller.isFirst = true
        controller.file = file
        controller.folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        controller.dismissBlock = { [unowned self] in
            self.getFolderFiles()
        }
        let nav = NavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc
    func createFolder() {
        let dialogViewController = QMUIDialogTextFieldViewController()
        dialogViewController.title = "新建文件夹"
        dialogViewController.addTextField(withTitle: nil) { (titleLabel, textField, separatorLayer) in
            textField.placeholder = "文件夹名"
            textField.maximumTextLength = 100
        }
        dialogViewController.shouldManageTextFieldsReturnEventAutomatically = true
        dialogViewController.addCancelButton(withText: "取消", block: nil)
        dialogViewController.addSubmitButton(withText: "确定") { [unowned self] d in
            d.hide()
            let name = dialogViewController.textFields![0].text!
            let path = self.indexFileURL.appendingPathComponent(name).path
            if FileManager.default.fileExists(atPath: path) {
                kAlert("文件夹已存在")
            } else {
                do {
                    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    QMUITips.showSucceed("新建成功", in: self.view).whiteStyle()
                    self.getFolderFiles()
                } catch let error {
                    print(message: error.localizedDescription)
                }
            }
        }
        dialogViewController.show()
    }
    
    func unZip(_ file: File) {
        let hud = QMUITips.showProgressView(self.view, status: "正在解压...")
        var toDirectoryURL = file.url.deletingPathExtension()
        if FileManager.default.fileExists(atPath: toDirectoryURL.path) {
            toDirectoryURL = URL(fileURLWithPath: toDirectoryURL.path + "_\(UInt.random(in: 1...1000000))")
        }
        print(message: "\(file.name)的解压文件夹：\(toDirectoryURL.absoluteString)")
        Async.background {
            SSZipArchive.unzipFile(atPath: file.url.path, toDestination: toDirectoryURL.path) { entry, zipInfo, entryNumber, total in
                Async.main {
                    hud.setProgress(CGFloat(entryNumber)/CGFloat(total), animated: true)
                }
            } completionHandler: { path, succeeded, error in
                Async.main {
                    hud.removeFromSuperview()
                    if succeeded {
                        self.getFolderFiles()
                        self.showSuccessAlert(alertTitle: "解压\(file.name)成功", fileURL: toDirectoryURL)
                    } else {
                        QMUITips.showInfo("解压失败\n\(error == nil ? "" : error!.localizedDescription)", in: self.view)
                    }
                }
            }
        }

    }
    
    func unArchiver(_ file: File, password: String) {

        QMUITips.showLoading("正在解压...", detailText: file.name, in: self.view).whiteStyle()
        Async.background {
            let destURL = file.url.deletingLastPathComponent().appendingPathComponent(file.url.deletingPathExtension().lastPathComponent)
            let result = XADHelper().unarchiver(withPath: file.url.path, dest: destURL.path, password: password)
            Async.main {
                QMUITips.hideAllTips()
                if result == 0 {
                    self.getFolderFiles()
                    self.showSuccessAlert(alertTitle: "解压\(file.name)成功！", fileURL: destURL)
                } else {
                    if let message = XADException.describeXADError(result) {
                        kAlert("解压失败！\(message)")
                    } else {
                        kAlert("解压失败！")
                    }
                }
            }
        }
    }

    func showSuccessAlert(alertTitle: String, fileURL: URL) {
        print(message: "fileURL:\(fileURL.path)")
        UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
        let alertController = QMUIAlertController.init(title: alertTitle, message: nil, preferredStyle: .alert)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            alertController.addAction(QMUIAlertAction.init(title: "查看", style: .default, handler: { _, _ in
                let controller = DocumentsViewController()
                controller.indexFileURL = fileURL
                controller.selectFileCallback = self.selectFileCallback
                controller.title = fileURL.lastPathComponent
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: controller, action: #selector(controller.dismissController))
                let nav = QMUINavigationController.init(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }))
        }
        alertController.addAction(QMUIAlertAction.init(title: "确定", style: .cancel, handler: nil))
        alertController.showWith(animated: true)
    }
}



