//
//  EntityType.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public protocol EntityType: class, Hashable {
  var identifier: String { get }
  
  init(identifier: String)
  init(jsonRepresentation json: [String: AnyObject])
  func jsonRepresentation() -> [String: AnyObject]
}

extension EntityType {
  
  public var hashValue: Int {
    return identifier.hashValue
  }
  
}
