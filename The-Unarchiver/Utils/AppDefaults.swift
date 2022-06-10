//
//  AppDefaults.swift
//  ABox
//
//  Created by SWING on 2022/5/10.
//

import UIKit

@propertyWrapper
public struct UserDefaultsItem<Value> {
    
    public let key: String
    
    public var wrappedValue: Value? {
        get {
            switch Value.self {
            case is Data.Type: return AppDefaults.shared.data(forKey: self.key) as? Value
            case is String.Type: return AppDefaults.shared.string(forKey: self.key) as? Value
            case is Bool.Type: return AppDefaults.shared.bool(forKey: self.key) as? Value
            default: return nil
            }
        }
        set {
            AppDefaults.shared.set(newValue, forKey: self.key)
        }
    }
    
    public init(key: String) {
        self.key = key
    }
}


class AppDefaults: UserDefaults {
    
    public static let shared = AppDefaults()
    
    @UserDefaultsItem(key: "deviceUDID")
    public var deviceUDID: String?
    
    @UserDefaultsItem(key: "deviceInfo")
    public var deviceInfo: String?
    
    @UserDefaultsItem(key: "aggreUserAgreement")
    public var aggreUserAgreement: Bool?
    
    @UserDefaultsItem(key: "signingCertificate")
    public var signingCertificate: Data?
    
    @UserDefaultsItem(key: "signingCertificateName")
    public var signingCertificateName: String?
    
    @UserDefaultsItem(key: "signingCertificateSerialNumber")
    public var signingCertificateSerialNumber: String?

    @UserDefaultsItem(key: "signingCertificatePassword")
    public var signingCertificatePassword: String?
    
    @UserDefaultsItem(key: "signingProvisioningProfile")
    public var signingProvisioningProfile: Data?
    
    public func reset() {
        self.deviceUDID = nil
        self.deviceInfo = nil
        self.aggreUserAgreement = nil
        self.signingCertificateName = nil
        self.signingCertificateSerialNumber = nil
        self.signingCertificate = nil
        self.signingCertificatePassword = nil
        self.signingProvisioningProfile = nil
    }
}
