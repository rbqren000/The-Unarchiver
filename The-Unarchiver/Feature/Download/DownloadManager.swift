//
//  DownloadManager.swift
//  ABox
//
//  Created by YZL-SWING on 2021/3/4.
//

import UIKit
import RxAlamofire
import Alamofire
import RxSwift

class DownloadManager {

    public static let shared = DownloadManager()
    let disposeBag = DisposeBag()

    func download(urlStr: String, fileName: String? = nil, downloadDirectoryURL: URL = FileManager.default.downloadDirectory, request: ((DownloadRequest) -> ())?, success: ((URL)->())?, failure: ((String)->())?) {
        // 下载路径
        var fileURL: URL!
        
        let destination: DownloadRequest.Destination = { url, response in
            if let name = fileName {
                // 自定义文件名
                fileURL = downloadDirectoryURL.appendingPathComponent(name)
            } else {
                // 文件名不变
                fileURL = downloadDirectoryURL.appendingPathComponent(response.suggestedFilename!)
            }
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        if let urlData = urlStr.data(using: String.Encoding.utf8) {
            if let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                // 开始下载
                RxAlamofire.download(API.httpURLRequest(url: url), to: destination)
                    .subscribe(onNext: { element in
                        request?(element)
                        print("开始下载。")
                    }, onError: { error in
                        print("下载失败! 失败原因：\(error)")
                        failure?(error.localizedDescription)
                    }, onCompleted: {
                        print("下载完毕!\(fileURL.absoluteString)")
                        success?(fileURL)
                    }).disposed(by: disposeBag)
            } else {
                failure?("下载链接无效！")
            }
        } else {
            failure?("下载链接无效！")
        }
    }
    
    func downloadIPA(urlStr: String, fileName: String? = nil, downloadDirectoryURL: URL = FileManager.default.downloadDirectory, completionHandler:((URL?, String?)->())?) {
        let hud = QMUITips.showProgressView(kAPPKeyWindow!, status: "请勿关闭对话框或退到后台，以免下载失败！")
        self.download(urlStr: urlStr, fileName: fileName, downloadDirectoryURL: downloadDirectoryURL) { request in
            // 下载进度
            request.downloadProgress(closure: { (p) in
                debugPrint(p.fractionCompleted, p.completedUnitCount / 1024, p.totalUnitCount / 1024)
                hud.setProgress(CGFloat(p.fractionCompleted), animated: true)
            })
        } success: { fileURL in
            hud.status = "下载完成"
            hud.removeFromSuperview()
            completionHandler?(fileURL, nil)
        } failure: { error in
            hud.status = "下载失败"
            hud.removeFromSuperview()
            completionHandler?(nil, error)
        }
    }
}
