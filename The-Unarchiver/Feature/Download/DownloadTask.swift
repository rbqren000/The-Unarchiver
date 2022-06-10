//
//  DownloadTask.swift
//  ABox
//
//  Created by YZL-SWING on 2020/12/3.
//

import UIKit
import Alamofire
import HandyJSON

enum DownloadTaskState: Int, HandyJSONEnum {
    case downloading = 0
    case finished = 1
    case error = 2
    case paused = 3
    case cancelled = 4
    case deleted = 5
}

class DownloadTask: NSObject {
    
    var httpClinet = DownloadManager()
    var downloadRequest: DownloadRequest?
    var info = DownloadTaskInfo()
    var downloadProgress = Progress()
    var downloadProgressHandle: ((Progress) -> ())?
    var downloadStateHandle: ((DownloadTaskState) -> ())?
    var downloadFinishHandle: ((DownloadTaskInfo) -> ())?

    func startDownload() {
        self.saveTaskInfo()
        if let url = URL(string: info.downloadURL) {
            self.httpClinet.download(urlStr: url.absoluteString, fileName: self.info.fileName) { request in
                self.downloadRequest = request
                request.downloadProgress(closure: { progress in
                    debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
                    self.downloadProgress = progress
                    self.downloadProgressHandle?(progress)
                })
            } success: { fileURL in
                self.info.fileName = fileURL.lastPathComponent
                self.info.fileType = fileURL.pathExtension.lowercased()
                do {
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                    if let fileSize:NSNumber = fileAttributes[FileAttributeKey.size] as! NSNumber? {
                        self.info.fileSize = String.fileSizeDesc(fileSize.intValue)
                    }
                } catch let error as NSError {
                    print("Get attributes errer: \(error)")
                }
                self.info.state = .finished
                self.downloadStateHandle?(self.info.state)
                self.downloadFinishHandle?(self.info)
                self.saveTaskInfo()
            } failure: { error in
                self.info.state = .error
                self.downloadStateHandle?(self.info.state)
                self.saveTaskInfo()
            }
        } else {
        }
    }
    
    func suspendTask() {
        print(message: "下载 suspendTask")
        self.info.state = .paused
        self.downloadStateHandle?(self.info.state)
        if let request = self.downloadRequest {
            request.suspend()
        } else {
            self.restartTask()
        }
        self.saveTaskInfo()
    }
    
    func resumeTask() {
        print(message: "下载 resumeTask")
        self.info.state = .downloading
        self.downloadStateHandle?(self.info.state)
        if let request = self.downloadRequest {
            request.resume()
        } else {
            self.restartTask()
        }
        self.saveTaskInfo()
    }
    
    func cancelTask() {
        print(message: "下载 cancelTask")
        self.info.state = .cancelled
        self.downloadStateHandle?(self.info.state)
        if let request = self.downloadRequest {
            request.cancel()
        } else {
            self.restartTask()
        }
        self.saveTaskInfo()
    }
    
    func restartTask() {
        self.info.state = .downloading
        self.downloadStateHandle?(self.info.state)
        self.startDownload()
    }

    func saveTaskInfo() {
        Client.shared.store?.createTable(withName: kDownloadTableName)
        self.info.createDate = Date().toString(.custom("yyyy-MM-dd HH:mm"))
        if let jsonString = self.info.toJSONString() {
            print(message: jsonString)
            Client.shared.store?.put(jsonString, withId: self.info.id, intoTable: kDownloadTableName)
        }
    }
}

class DownloadTaskInfo: HandyJSON {
    var state = DownloadTaskState.finished
    var downloadURL = ""
    var fileSize = "0.0 Bytes"
    var fileName: String?
    var fileType = ""
    var createDate = ""
    var id = NSUUID().uuidString
    required init() {}
}
