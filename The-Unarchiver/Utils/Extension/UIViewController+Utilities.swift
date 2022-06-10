//
//  ViewController+Utilities.swift
//  ABox
//
//  Created by YZL-SWING on 2021/2/24.
//

import Foundation
import SafariServices
import Async

extension UIViewController {
        
    func openURLWithSafari(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.configuration.entersReaderIfAvailable = false
        safariVC.configuration.barCollapsingEnabled = false
        safariVC.dismissButtonStyle = .close
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func openURLWithWebView(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.configuration.entersReaderIfAvailable = false
        safariVC.configuration.barCollapsingEnabled = false
        safariVC.dismissButtonStyle = .close
        self.present(safariVC, animated: true, completion: nil)
    }
    
}
