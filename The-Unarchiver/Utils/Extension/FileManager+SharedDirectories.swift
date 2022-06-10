//
//  FileManager+SharedDirectories.swift
//  AltStore
//
//  Created by Riley Testut on 5/14/20.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

import Foundation

public extension FileManager {
    
    var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var cacheDirectory: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    var importFileDirectory: URL {
        return self.documentDirectory.appendingPathComponent("导入的文件", isDirectory: true)
    }
    
//    var importPhotoDirectory: URL {
//        return self.documentDirectory.appendingPathComponent("导入的照片", isDirectory: true)
//    }
//
//    var importVideoDirectory: URL {
//        return self.documentDirectory.appendingPathComponent("导入的视频", isDirectory: true)
//    }

    
    var downloadDirectory: URL {
        return self.documentDirectory.appendingPathComponent("下载项", isDirectory: true)
    }

    var recycleBinDirectory: URL {
        return self.cacheDirectory.appendingPathComponent(".MyRecycle", isDirectory: true)
    }
    
    var unzipIPADirectory: URL {
        return self.cacheDirectory.appendingPathComponent(".UnzipIPA", isDirectory: true)
    }

    var classdumpDirectory: URL {
        return self.documentDirectory.appendingPathComponent("Class-Dump", isDirectory: true)
    }

    func createDefaultDirectory() {
        let urls = [FileManager.default.importFileDirectory,
                    FileManager.default.downloadDirectory,
                    FileManager.default.recycleBinDirectory]
        for url in urls {
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                } catch let error {
                    print(message: error.localizedDescription)
                }
            }
        }
    }
    

}

