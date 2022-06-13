//
//  API.swift
//  ABox
//
//  Created by YZL-SWING on 2020/11/16.
//

import UIKit
import RxAlamofire
import Alamofire
import RxSwift
import HandyJSON

class API {

    static let `default` = API()
//    let appBaseURL = "https://swing1993.cn:8888"
    let appBaseURL = "http://101.43.69.240:8080"
    let disposeBag = DisposeBag()
    
    func request(url: String, method: Alamofire.HTTPMethod = .get, parameters: [String: Any]? = nil, success: ((Any?)->())?, failure: ((String)->())?) {
        let requestUrl = appBaseURL + url
        
        RxAlamofire.requestString(method, URL(string: requestUrl)!, parameters: parameters, headers: API.httpRqeusetHeaders()).subscribe { (response, responseString) in
//            print(message: "requestUrl:\(requestUrl)\nparameters:\(String(describing: parameters))\nresponse:\(responseString)")
            if let httpResult = HttpResponse.deserialize(from: responseString) {
                if httpResult.success {
                    success?(httpResult.result)
                } else {
                    failure?(httpResult.message)
                }
            } else {
                failure?("服务器开小差了")
            }
        } onError: { error in
            failure?(error.localizedDescription)
        }.disposed(by: disposeBag)
    }

    static func httpRqeusetHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        headers["osVersion"] = "\(kVersion)"
        if let appVersion: String = kAppVersion! as? String {
            if let appBuildVersion: String = kAppBuildVersion! as? String {
                headers["version"] = "\(appVersion)(\(appBuildVersion))"
            }
        }
        return headers
    }
    
    static func httpURLRequest(url: URL) -> URLRequest {
        var request = URLRequest.init(url: url)
        let headers = API.httpRqeusetHeaders().dictionary
        for key in headers.keys {
            if let value = headers[key] {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
}


/// MARK: - Result
class HttpResponse: HandyJSON {
    var message: String = "服务器开小差了"
    var error: String = ""
    var result: Any?
    var code: Int = 0
    var success = true
    var timestamp = ""
    var encrypt = false
    required init() {}
}
