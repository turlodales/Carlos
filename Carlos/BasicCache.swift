//
//  BasicCache.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 07/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// A wrapper cache that explicitly takes get, set, clear and memory warning closures
public class BasicCache<A, B>: CacheLevel {
  public typealias KeyType = A
  public typealias OutputType = B
  
  private let getClosure: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void
  private let setClosure: (key: A, value: B) -> Void
  private let clearClosure: () -> Void
  private let memoryClosure: () -> Void
  
  public init(getClosure: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void, setClosure: (key: A, value: B) -> Void, clearClosure: () -> Void, memoryClosure: () -> Void) {
    self.getClosure = getClosure
    self.setClosure = setClosure
    self.clearClosure = clearClosure
    self.memoryClosure = memoryClosure
  }
  
  public func get(fetchable: A, onSuccess success: (B) -> Void, onFailure failure: (NSError?) -> Void) {
    getClosure(key: fetchable, success: success, failure: failure)
  }
  
  public func set(value: B, forKey fetchable: A) {
    setClosure(key: fetchable, value: value)
  }
  
  public func clear() {
    clearClosure()
  }
  
  public func onMemoryWarning() {
    memoryClosure()
  }
}