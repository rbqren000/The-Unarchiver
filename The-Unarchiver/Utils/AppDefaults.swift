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
    
    @UserDefaultsItem(key: "alreadyInstalled")
    public var alreadyInstalled: Bool?
        
    @UserDefaultsItem(key: "unarchiverExtractsubarchives")
    public var unarchiverExtractsubarchives: Bool?
    
//    @UserDefaultsItem(key: "unarchiverRemovesolo")
//    public var unarchiverRemovesolo: Bool?
    
    @UserDefaultsItem(key: "unarchiverOverwrite")
    public var unarchiverOverwrite: Bool?
    
    @UserDefaultsItem(key: "unarchiverRename")
    public var unarchiverRename: Bool?
    
    @UserDefaultsItem(key: "unarchiverSkip")
    public var unarchiverSkip: Bool?
    
//    @UserDefaultsItem(key: "unarchiverCopydatetoenclosing")
//    public var unarchiverCopydatetoenclosing: Bool?
//
//    @UserDefaultsItem(key: "unarchiverCopydatetosolo")
//    public var unarchiverCopydatetosolo: Bool?
//
//    @UserDefaultsItem(key: "unarchiverResetsolodate")
//    public var unarchiverResetsolodate: Bool?
    
    @UserDefaultsItem(key: "unarchiverPropagatemetadata")
    public var unarchiverPropagatemetadata: Bool?

    public func reset() {
        self.unarchiverExtractsubarchives = true
        self.unarchiverOverwrite = false
        self.unarchiverRename = false
        self.unarchiverSkip = false
        self.unarchiverPropagatemetadata = true
    }
}
