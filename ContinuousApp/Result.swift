//
//  Result.swift
//  ShoppingLister
//
//  Copyright © 2018 AppTrix AB. All rights reserved.
//

import Foundation

public enum Result<Value> {

  case success(Value)
  case failure(Error)

  public var value: Value? {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  public var error: Error? {
    switch self {
    case .success:
      return nil
    case .failure(let error):
      return error
    }
  }
}
