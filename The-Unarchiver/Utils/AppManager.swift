//
//  AppManager.swift
//  ABox
//
//  Created by YZL-SWING on 2021/1/14.
//

import UIKit
import Async

class AppManager: NSObject {
    
    static let `default` = AppManager()
    private var webServer: GCDWebServer?
    private let kInstallURL = URL(string: "itms-services://?action=download-manifest&url=https://gitee.com/swing1993/manifest/raw/master/manifest.plist")!
    private let kInstallWithIconURL = URL(string: "itms-services://?action=download-manifest&url=https://gitee.com/swing1993/manifest/raw/master/ipa.plist")!
    private var installApp = false

//    func installApp(ipaURL: URL, icon: UIImage? = nil) {

    func requestFile(_ fileURL: URL, icon: UIImage? = nil) {
        do {
            let appData = try Data.init(contentsOf: fileURL, options: .mappedIfSafe)
            self.initWebServer()
            self.startAppInstallWebServer(appData: appData, icon: icon)
        } catch _ {
            kAlert("无法安装应用")
        }
    }

    private func initWebServer() {
        if let webServer = self.webServer {
            if webServer.isRunning {
                print(message: "webServer isRunning... STOP")
                webServer.stop()
            }
            self.webServer = nil
        }
        self.webServer = GCDWebServer()
        self.webServer?.delegate = self
    }
    
    private func startAppInstallWebServer(appData: Data, icon: UIImage?) {
        var installURL = kInstallURL
        
        if let iconData = icon?.pngData() {
            installURL = kInstallWithIconURL
            webServer?.addHandler(forMethod: "GET", path: "/applogo.png", request: GCDWebServerRequest.self, processBlock: { request -> GCDWebServerResponse? in
                print(message: request)
                return GCDWebServerDataResponse.init(data: iconData, contentType: "image/png")
            })
        }
        
        self.installApp = true
        webServer?.addHandler(forMethod: "GET", path: "/app.ipa", request: GCDWebServerRequest.self, processBlock: { request -> GCDWebServerResponse? in
            print(message: request)
            return GCDWebServerDataResponse.init(data: appData, contentType: "application/octet-stream")
        })
        
        webServer?.start(withPort: 8881, bonjourName: "GCD Web Server")
        print("Visit \(String(describing: webServer!.serverURL)) in your web browser")
        Async.main(after: 0.1, {
            UIApplication.shared.open(installURL, options: [:], completionHandler: nil)
        })
    }

}

extension AppManager: GCDWebServerDelegate {

    func webServerDidStart(_ server: GCDWebServer) {
        print(message: "webServerDidStart")
    }
    
    func webServerDidConnect(_ server: GCDWebServer) {
        print(message: "webServerDidConnect")
        if self.installApp && !showingAlert {
            QMUITips.showLoading("正在安装应用，请勿关闭对话框或退到后台，以免安装失败！", in: kAPPKeyWindow!).whiteStyle()
        }
    }
    
    func webServerDidDisconnect(_ server: GCDWebServer) {
        print(message: "webServerDidDisconnect")
        if self.installApp {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                QMUITips.hideAllTips()
                kAlert("App已载入完成，请返回桌面查看安装进度", showCancel: true, preferredStyle: .actionSheet, callBack: {
                    UIApplication.shared.perform(#selector(URLSessionTask.suspend))
                })
            }
        }
    }
    
    func webServerDidStop(_ server: GCDWebServer) {
        print(message: "webServerDidStop")
    }
}


