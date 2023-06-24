//
//  UserDefault.swift
//  userapp
//
//  Created by Tommy Sadiq Hinrichsen on 05/04/2020.
//  Copyright © 2020 Tommy Sadiq Hinrichsen. All rights reserved.
//

import Foundation

@propertyWrapper
open class UserDefault<Value: Codable> {

    fileprivate var key: String
    fileprivate var defaultValue: Value

    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    open var wrappedValue: Value {
        get { UserDefaults.standard.decodeObject(forKey: key) ?? self.defaultValue }
        set { UserDefaults.standard.encode(newValue, forKey: key) }
    }
}

@propertyWrapper
open class UserDefaultOptional<Value: Codable> {

    fileprivate var key: String

    public  init(_ key: String) {
        self.key = key
    }

    open var wrappedValue: Value? {
        get { UserDefaults.standard.decodeObject(forKey: key) }
        set { UserDefaults.standard.encode(newValue, forKey: key) }
    }
}
