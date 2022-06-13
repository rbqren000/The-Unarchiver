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
        
    @UserDefaultsItem(key: "impactFeedback")
    public var impactFeedback: Bool?
    
    public func reset() {
       
    }
}
