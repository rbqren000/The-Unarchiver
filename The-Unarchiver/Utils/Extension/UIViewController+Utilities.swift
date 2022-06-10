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
    
    func openIPA(url: URL, unzipHandler: ((Bool, URL) -> Void)? = nil) {
        
        var tipMessage = "安装期间请不要退出对话框，否则可能会导致安装失败。"
        let alertController = QMUIAlertController.init(title: url.lastPathComponent, message: tipMessage, preferredStyle: .actionSheet)

//        if let unzipHandler = unzipHandler {
//            alertController.addAction(QMUIAlertAction.init(title: "解压", style: .default, handler: { _, _ in
//
//                let hud = QMUITips.showProgressView(self.view, status: "正在解压IPA...")
//                let outputDirectoryURL = url.deletingPathExtension()
//                Async.main(after: 0.1, {
//                    let appSigner = AppSigner()
//                    appSigner.unzipAppBundle(at: url,
//                                             outputDirectoryURL: outputDirectoryURL,
//                                             progressHandler: { entry, zipInfo, entryNumber, total in
//                        Async.main {
//                            hud.setProgress(CGFloat(entryNumber)/CGFloat(total), animated: true)
//                        }
//                    },
//                                             completionHandler: { (success, application, error) in
//                        Async.main {
//                            unzipHandler(success, outputDirectoryURL)
//                            hud.removeFromSuperview()
//                        }
//                    })
//                })
//            }))
//        }
        
        alertController.addAction(QMUIAlertAction.init(title: "安装", style: .destructive, handler: { _, _ in
//            AppManager.default.installApp(ipaURL: url)
        }))

        alertController.addAction(QMUIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        alertController.showWith(animated: true)
    }
    
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
