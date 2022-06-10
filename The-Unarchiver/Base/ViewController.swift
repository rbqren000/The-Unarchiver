//
//  ViewController.swift
//  ABox
//
//  Created by YZL-SWING on 2020/11/6.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: QMUICommonViewController {

    let disposeBag = DisposeBag()
    
    override func initSubviews() {
        super.initSubviews()
        self.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.supportedOrientationMask = .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func shouldHideKeyboardWhenTouch(in view: UIView?) -> Bool {
        return true
    }
    
}


