//
//  AnyDiffable.swift
//  DiffingAlgorithm
//
//  Created by Ambar Septian on 11/04/20.
//  Copyright © 2020 Ambar Septian. All rights reserved.
//

import Foundation

public protocol Diffable: Hashable {
    
    var primaryKeyValue: String { get }
    
}

public struct AnyDiffable: Diffable {
    
    private let _primaryKeyValue: () -> String
    
    var base: AnyHashable
    
    public init<D: Diffable>(_ base: D) {
        self.base = base
        _primaryKeyValue = { base.primaryKeyValue }
    }
    
    public static func == (x: AnyDiffable, y: AnyDiffable) -> Bool {
        return x.base == y.base
    }
    
    public var hashValue: Int {
        return base.hashValue
    }
    
    public var primaryKeyValue: String {
        return _primaryKeyValue()
    }
    
}

extension AnyDiffable {
    
    /// Evaluates the given closure when this `AnyDiffable` instance is type `T`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `map` method with a closure that returns a nonoptional value.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is not type T,
    ///   returns `self`.
    func map<T: Diffable, U: Diffable>(_ transform: (T) throws -> U) rethrows -> AnyDiffable {
        
        guard let object = base as? T else {
            return self
        }
        
        return try AnyDiffable(transform(object))
    }
    
    /// Evaluates the given closure when this `AnyDiffable` instance is not `nil`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `flatMap` method with a closure that returns an optional value.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is `nil`,
    ///   returns `nil`.
    func flatMap<T: Diffable, U: Diffable>(_ transform: (T) throws -> U?) rethrows -> AnyDiffable? {
       
        guard let object = base as? T else {
            return .none
        }
        
        switch try transform(object) {
            
        case (let wrapped)? where wrapped is AnyDiffable:
            return wrapped as? AnyDiffable
            
        case (let wrapped)?:
           return AnyDiffable(wrapped)
            
        case .none:
            return .none
            
        }

    }
    
    /// Evaluates the given closure when this `AnyDiffable` instance is not `nil`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `apply` method with an optional closure that returns a nonoptional value.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If the closure is `nil`,
    ///   returns `nil`.
    func apply<T: Diffable, U: Diffable>(transform: ((T) throws -> U)?) throws -> AnyDiffable? {
        return try transform.flatMap(map)
    }
}
    
