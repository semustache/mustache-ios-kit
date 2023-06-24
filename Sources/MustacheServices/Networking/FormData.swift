//
//  File.swift
//  
//
//  Created by Tommy Sadiq Hinrichsen on 13/01/2023.
//

import Foundation

public enum FormData {
    case text(key: String, value: String)
    case data(key: String, fileName: String, contentType: String, value: Data)
}
