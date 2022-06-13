//
//  LicensesViewController.swift
//  The-Unarchiver
//
//  Created by SWING on 2022/6/13.
//

import UIKit

class LicensesViewController: ViewController {

    var tableView = QMUITableView.init(frame: CGRect.zero, style: .grouped)

    let cellIdentifier = "LicensesCell"
    let cellData = [(name: "XADMaster",
                     desc: "file unarchiving and extraction",
                     url: "https://github.com/MacPaw/XADMaster/blob/master/LICENSE"),
                    (name: "SSZipArchive",
                     desc: "a simple utility class for zipping and unzipping files.",
                     url: "https://github.com/wuhaiwei/SSZipArchive/blob/master/LICENSE"),
                    (name: "Alamofire",
                     desc: "Elegant HTTP Networking in Swift",
                     url: "https://github.com/Alamofire/Alamofire/blob/master/LICENSE"),
                    (name: "MJRefresh",
                     desc: "An easy way to use pull-to-refresh",
                     url: "https://github.com/CoderMJLee/MJRefresh/blob/master/LICENSE"),
                    (name: "SnapKit",
                     desc: "A Swift Autolayout DSL",
                     url: "https://github.com/SnapKit/SnapKit/blob/develop/LICENSE"),
                    (name: "Async",
                     desc: "Syntactic sugar in Swift for asynchronous dispatches in Grand Central Dispatch",
                     url: "https://github.com/duemunk/Async/blob/master/LICENSE.txt"),
                    (name: "RxSwift",
                     desc: "Reactive Programming in Swift",
                     url: "https://github.com/ReactiveX/RxSwift/blob/main/LICENSE.md"),
                    (name: "HandyJSON",
                     desc: "A handy swift json-object serialization/deserialization library",
                     url: "https://github.com/alibaba/HandyJSON/blob/master/LICENSE"),
                    (name: "FMDB",
                     desc: "an Objective-C wrapper around SQLite",
                     url: "https://github.com/ccgus/fmdb/blob/master/LICENSE.txt")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Licenses"
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


extension LicensesViewController: QMUITableViewDelegate, QMUITableViewDataSource {
    
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
        cell?.detailTextLabel?.text = item.desc
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.cellData[indexPath.row]
        self.openURLWithSafari(URL(string: item.url)!)

    }
    


}

