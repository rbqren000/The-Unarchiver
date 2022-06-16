//
//  Client.swift
//  ABox
//
//  Created by YZL-SWING on 2020/11/23.
//

import UIKit
import HandyJSON

class Client: NSObject {
    
    public static let shared = Client()

    let store = YTKKeyValueStore.init(dbWithName: ".Unarchiver.db")
    var webUploader: GCDWebUploader?
    var davServer: GCDWebDAVServer?
    var unarchiverTask: Bool = false
    
    func webUploader(start: Bool, port: UInt = 5050) {
        if self.webUploader == nil {
            self.webUploader = GCDWebUploader(uploadDirectory: FileManager.default.documentDirectory.path)
        }
        
        if let webUploader = self.webUploader {
            if webUploader.isRunning && start == false {
                webUploader.stop()
            }
            if webUploader.isRunning == false && start {
                let started = webUploader.start(withPort: port, bonjourName: "Unarchiver")
                if started && webUploader.serverURL != nil {
                    print(message: "Visit \(webUploader.serverURL?.absoluteString) in your Web client")
                } else {
                    print(message: "暂时无法开启WebDAV，请稍后再试。")
                }
            }
        }
    }
    
    func webDAVServer(start: Bool, port: UInt = 8080, bonjourName: String = "Unarchiver") {
        if self.davServer == nil {
            davServer = GCDWebDAVServer.init(uploadDirectory: FileManager.default.documentDirectory.path)
            davServer?.delegate = self
        }
        
        if let davServer = davServer {
            if davServer.isRunning && start == false {
                davServer.stop()
            }
            if davServer.isRunning == false && start {
                let started = davServer.start(withPort: port, bonjourName: bonjourName)
                if started && davServer.serverURL != nil {
                    print(message: "Visit \(davServer.serverURL?.absoluteString) in your WebDAV client")
                } else {
                    print(message: "暂时无法开启WebDAV，请稍后再试。")
                }
            }
        }
        
    }
}

extension Client: GCDWebDAVServerDelegate {
    
    func davServer(_ server: GCDWebDAVServer, didDeleteItemAtPath path: String) {
        print(message: "WebDAVServer didDeleteItemAtPath:\(path)")
    }
    
    func davServer(_ server: GCDWebDAVServer, didUploadFileAtPath path: String) {
        print(message: "WebDAVServer didUploadFileAtPath:\(path)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didDownloadFileAtPath path: String) {
        print(message: "WebDAVServer didDownloadFileAtPath:\(path)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didCreateDirectoryAtPath path: String) {
        print(message: "WebDAVServer didCreateDirectoryAtPath:\(path)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didCopyItemFromPath fromPath: String, toPath: String) {
        print(message: "WebDAVServer didCopyItemFromPath:\(fromPath) toPath:\(toPath)")

    }
    
    func davServer(_ server: GCDWebDAVServer, didMoveItemFromPath fromPath: String, toPath: String) {
        print(message: "WebDAVServer didMoveItemFromPath:\(fromPath) toPath:\(toPath)")

    }
}
