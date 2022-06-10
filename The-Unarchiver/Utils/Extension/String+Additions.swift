//
//  String+Additions.swift
//  YuZhiLai
//
//  Created by YZL-SWING on 2019/7/19.
//  Copyright © 2019 YanFeng. All rights reserved.
//

import Foundation
import SwiftDate

extension String {
        
    // unicode转中文
    var unicodeStr: String {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: String.Encoding.utf8)
        var returnStr:String = self
        do {
            returnStr = try PropertyListSerialization.propertyList(from: tempData!, options: [.mutableContainers], format: nil) as! String
        } catch {
            print(error)
        }
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }
    
    var utf8Str: String {
        if let value = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return value
        }
        return self
    }
    
    static func MMSSFormat(interval: TimeInterval) -> String {
        let ti: Int = Int(interval)
        let seconds: Int = ti % 60
        let minutes: Int = (ti / 60) % 60
        return String(format: "%02d:%02d", minutes,seconds)
    }
    
    static func HHMMSSFormat(interval: TimeInterval) -> String {
        let ti: Int = Int(interval)
        let seconds: Int = ti % 60
        let minutes: Int = (ti / 60) % 60
        let hours: Int = ti / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    static func isEmoji(_ scalar: Unicode.Scalar) -> Bool {
        switch Int(scalar.value) {
        case 0x1F601...0x1F64F: return true // Emoticons
        case 0x1F600...0x1F636: return true // Additional emoticons
        case 0x2702...0x27B0: return true // Dingbats
        case 0x1F680...0x1F6C0: return true // Transport and map symbols
        case 0x1F681...0x1F6C5: return true // Additional transport and map symbols
        case 0x24C2...0x1F251: return true // Enclosed characters
        case 0x1F30D...0x1F567: return true // Other additional symbols
        default: return false
        }
    }
    
    /**
     匹配字符串中所有的URL
     */
    static func getUrls(str:String) -> [String] {
        var urls = [String]()
        // 创建一个正则表达式对象
        do {
            let dataDetector = try NSDataDetector(types:
                                                    NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
            // 匹配字符串，返回结果集
            let res = dataDetector.matches(in: str,
                                           options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                           range: NSMakeRange(0, str.count))
            // 取出结果
            for checkingRes in res {
                urls.append((str as NSString).substring(with: checkingRes.range))
            }
        }
        catch {
            print(error)
        }
        return urls
    }
    
    static func timeStr(_ date: Date?) -> String {
        if let date = date {
            let calendar = Calendar.current
            var result = ""
            var formatterSr = "HH:mm"
            if calendar.isDateInToday(date) { //今天
                let interval = Int(NSDate().timeIntervalSince(date))  //比较两个时间的差值
                if interval < 60 {
                    result = "刚刚"
                } else if interval < 60 * 60 {
                    result = "\(interval/60)分钟前"
                } else if interval < 60 * 60 * 24 {
                    result = "\(interval / (60 * 60))小时前"
                }
            } else if calendar.isDateInYesterday(date) {  //昨天
                formatterSr = "昨天 " + formatterSr
                result = date.toString(.custom(formatterSr))
            } else {
                if Date().year == date.year {
                    //今年以内
                    formatterSr = "MM-dd " + formatterSr
                } else {
                    formatterSr = "yyyy-MM-dd " + formatterSr
                }
                result = date.toString(.custom(formatterSr))
            }
            return result
        }
        return ""
    }
    
    
    static func fileSizeDesc(_ aSize: Int) -> String {
        let floatValue = Float(aSize)
        var sizeDesc = ""
        if floatValue < 1000 {
            sizeDesc = String(format: "%0.2fBytes", floatValue)
        } else if floatValue > 1000 && floatValue < 1000 * 1000 {
            sizeDesc = String(format: "%0.2fKB", floatValue/1000)
        } else if floatValue > 1000 * 1000 && floatValue < 1000 * 1000 * 1000 {
            sizeDesc = String(format: "%0.2fMB", floatValue/(1000 * 1000))
        } else {
            sizeDesc = String(format: "%0.2fGB", floatValue/(1000 * 1000 * 1000))
        }
        return sizeDesc
    }
    
    /*
     *去掉首尾空格
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉首尾空格 包括后面的换行 \n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    
}


