//
//  Keychain.swift
//  userapp
//
//  Created by Tommy Sadiq Hinrichsen on 05/04/2020.
//  Copyright © 2020 Tommy Sadiq Hinrichsen. All rights reserved.
//

import Foundation

@propertyWrapper
open class Keychain<Value: Codable> {

    fileprivate var key: String
    fileprivate var defaultValue: Value
    fileprivate var accessibility: KeychainItemAccessibility

    public init(_ key: String, defaultValue: Value, accessibility: KeychainItemAccessibility = .afterFirstUnlock) {
        self.key = key
        self.defaultValue = defaultValue
        self.accessibility = accessibility
    }

    open var wrappedValue: Value {
        get {
            guard let data = KeychainWrapper.standard.data(forKey: self.key, withAccessibility: self.accessibility) else { return self.defaultValue }
            guard let value = try? JSONDecoder().decode([Value].self, from: data).first else { return self.defaultValue }
            return value
        }
        set {
            guard let data = try? JSONEncoder().encode([newValue]) else {
                KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: self.accessibility)
                return
            }
            let success = KeychainWrapper.standard.set(data, forKey: self.key, withAccessibility: self.accessibility)
            if !success {
                for accessibility in KeychainItemAccessibility.allCases {
                    KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: accessibility)
                }
                KeychainWrapper.standard.set(data, forKey: self.key, withAccessibility: self.accessibility)
            }
            
        }
    }
}

@propertyWrapper
open class KeychainOptional<Value: Codable> {

    fileprivate var key: String
    fileprivate var accessibility: KeychainItemAccessibility

    public  init(_ key: String, accessibility: KeychainItemAccessibility = .afterFirstUnlock) {
        self.key = key
        self.accessibility = accessibility
    }

    open var wrappedValue: Value? {
        get {
            guard let data = KeychainWrapper.standard.data(forKey: self.key, withAccessibility: self.accessibility) else { return nil }
            guard let value = try? JSONDecoder().decode([Value].self, from: data).first else { return nil }
            return value
        }
        set {
            guard let value = newValue else {
                KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: self.accessibility)
                return
            }
            guard let data = try? JSONEncoder().encode([value]) else {
                KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: self.accessibility)
                return
            }
            let success = KeychainWrapper.standard.set(data, forKey: self.key, withAccessibility: self.accessibility)
            if !success {
                for accessibility in KeychainItemAccessibility.allCases {
                    KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: accessibility)
                }
                KeychainWrapper.standard.set(data, forKey: self.key, withAccessibility: self.accessibility)
            }
            
        }
    }
}
