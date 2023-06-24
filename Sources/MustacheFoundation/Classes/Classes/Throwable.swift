//
//  Throwable.swift
//  MustacheFoundation
//
//  Created by Tommy Hinrichsen on 07/10/2019.
//

import Foundation

//  init(from decoder: Decoder) throws {
//      let container = try decoder.container(keyedBy: CodingKeys.self)
//      let guardedData = try container.decode([Throwable<T>].self, forKey: .key)
//      self.property = guardedData.compactMap { $0.value }
//  }

public enum Throwable<T: Decodable>: Decodable {

    case success(T)
    case failure(Error)

    public init(from decoder: Decoder) throws {
        do {
            let decoded = try T(from: decoder)
            self = .success(decoded)
        } catch let error {
            self = .failure(error)
        }
    }
}

public extension Throwable {

    var value: T? {
        switch self {
            case .failure(_):
                return nil
            case .success(let value):
                return value
        }
    }
}

