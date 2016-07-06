//
//  Entity.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public final class Entity: EntityType {
  
  public let identifier: String!
  
  public init(identifier: String = NSUUID().UUIDString) {
    self.identifier = identifier
  }
  
  public init(jsonRepresentation json: [String : AnyObject]) {
    guard let identifier = json["identifier"] as? String else {
      fatalError("Identifier not found!")
    }
    
    self.identifier = identifier
  }
  
  public func jsonRepresentation() -> [String : AnyObject] {
    return ["identifier": identifier]
  }
  
}

public func ==(lhs: Entity, rhs: Entity) -> Bool {
  return lhs.identifier == rhs.identifier
}
