//
//  Singleton.swift
//  userapp
//
//  Created by Tommy Sadiq Hinrichsen on 05/04/2020.
//  Copyright © 2020 Tommy Sadiq Hinrichsen. All rights reserved.
//

import Foundation

fileprivate class SingletonStorage {
    fileprivate static var singles = [String: Any]()
}

@propertyWrapper
open class Singleton<Value> {

    fileprivate var key: String
    fileprivate var defaultValue: Value

    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    open var wrappedValue: Value {
        get { return (SingletonStorage.singles[self.key] as? Value) ?? self.defaultValue }
        set { SingletonStorage.singles[self.key] = newValue }
    }
}

@propertyWrapper
open class SingletonOptional<Value> {

    fileprivate var key: String

    public  init(_ key: String) {
        self.key = key
    }

    open var wrappedValue: Value? {
        get { return SingletonStorage.singles[self.key] as? Value }
        set { SingletonStorage.singles[self.key] = newValue }
    }
}
