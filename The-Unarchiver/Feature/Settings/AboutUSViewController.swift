//
//  AboutUSViewController.swift
//  ABox
//
//  Created by YZL-SWING on 2020/11/18.
//

import UIKit

class AboutUSViewController: ViewController {
    
    let appIcon = UIImageView(image: UIImage(named: "icon-1024"))
    let versionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于我们"
    }
    
    override func initSubviews() {
        super.initSubviews()
        self.view.addSubview(appIcon)
        appIcon.snp.makeConstraints { maker in
            maker.width.height.equalTo(175)
            maker.centerX.equalTo(self.view)
            maker.bottom.equalTo(self.view.snp.centerY)
        }
        
        versionLabel.textAlignment = .center
        versionLabel.text = "\(kAppDisPlayName!) v\(kAppVersion!)\n\(NSString.bulidDate())"
        versionLabel.font = UIFont.medium(aSize: 18)
        versionLabel.numberOfLines = 2
        versionLabel.textColor = kTextColor
        self.view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { maker in
            maker.left.right.equalTo(0)
            maker.height.equalTo(100)
            maker.top.equalTo(appIcon.snp.bottom).offset(5)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
