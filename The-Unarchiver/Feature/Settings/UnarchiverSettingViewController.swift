//
//  UnarchiverSettingViewController.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/13.
//

import UIKit


class UnarchiverSetting {
    var unarchiverOverwrite = false
    var unarchiverRename = false
    var unarchiverSkip = false
    var unarchiverExtractsubarchives = false
    var unarchiverCopydatetoenclosing = false
    var unarchiverCopydatetosolo = false
    var unarchiverResetsolodate = false
    var unarchiverPropagatemetadata = false
}

class UnarchiverSettingViewController: ViewController {

    var tableView = QMUITableView.init(frame: CGRect.zero, style: .grouped)

    let cellIdentifier = "UnarchiverSettingCell"
    var cellData = [(name: "始终覆盖文件",
                     desc: "alwaysOverwritesFiles",
                     value: AppDefaults.shared.unarchiverOverwrite!),
                    (name: "始终重命名文件",
                     desc: "alwaysRenamesFiles",
                     value: AppDefaults.shared.unarchiverRename!),
                    (name: "始终跳过文件",
                     desc: "alwaysSkipsFiles",
                     value: AppDefaults.shared.unarchiverSkip!),
                    (name: "自动解压子存档",
                     desc: "extractsSubArchives",
                     value: AppDefaults.shared.unarchiverExtractsubarchives!),
//                    (name: "修改存档时间到目录",
//                     desc: "copiesArchiveModificationTimeToEnclosingDirectory",
//                     value: AppDefaults.shared.unarchiverCopydatetoenclosing!),
//                    (name: "副本存档修改时间到独奏项",
//                     desc: "copiesArchiveModificationTimeToSoloItems",
//                     value: AppDefaults.shared.unarchiverCopydatetosolo!),
//                    (name: "重置单个项的日期",
//                     desc: "resetsDateForSoloItems",
//                     value: AppDefaults.shared.unarchiverResetsolodate!),
                    (name: "自动设置相关元数据",
                     desc: "propagatesRelevantMetadata",
                     value: AppDefaults.shared.unarchiverPropagatemetadata!)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "解压设置"
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
    
  
    func cofingSwitchView(tag: Int, isOn: Bool) -> UISwitch {
        let switchView = UISwitch()
        switchView.tag = tag
        switchView.isOn = isOn
        switchView.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        return switchView
    }
    
    @objc
    func switchValueChanged(sender: UISwitch) {
        print(message: "isOn:\(sender.isOn)")
        switch sender.tag {
        case 0:
            AppDefaults.shared.unarchiverOverwrite = sender.isOn
        case 1:
            AppDefaults.shared.unarchiverRename = sender.isOn
        case 2:
            AppDefaults.shared.unarchiverSkip = sender.isOn
        case 3:
            AppDefaults.shared.unarchiverExtractsubarchives = sender.isOn
//        case 4:
//            AppDefaults.shared.unarchiverCopydatetoenclosing = sender.isOn
//        case 5:
//            AppDefaults.shared.unarchiverCopydatetosolo = sender.isOn
//        case 6:
//            AppDefaults.shared.unarchiverResetsolodate = sender.isOn
//        case 7:
//            AppDefaults.shared.unarchiverPropagatemetadata = sender.isOn
        default:
            AppDefaults.shared.unarchiverPropagatemetadata = sender.isOn
        }

    }
    
}


extension UnarchiverSettingViewController: QMUITableViewDelegate, QMUITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = QMUITableViewCell(for: tableView, with: .subtitle, reuseIdentifier: identifier)
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.medium(aSize: 14)
            cell?.textLabel?.textColor = kTextColor
            cell?.detailTextLabel?.font = UIFont.regular(aSize: 11)
            cell?.detailTextLabel?.textColor = kSubtextColor
        }
        
        cell?.accessoryType = .disclosureIndicator
        let item = self.cellData[indexPath.row]
        cell?.textLabel?.text = item.name
        cell?.detailTextLabel?.text = ""
//        cell?.detailTextLabel?.text = item.desc
        cell?.accessoryView = self.cofingSwitchView(tag: indexPath.row, isOn: item.value)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
}
