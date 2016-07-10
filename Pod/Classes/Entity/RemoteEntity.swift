//
//  RemoteEntity.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public final class RemoteEntity: EntityType {
  
  public let identifier: String
  public var remoteURI: String?
  
  public init(identifier: String = NSUUID().UUIDString) {
    self.identifier = identifier
  }
  
  public init(jsonRepresentation json: [String : AnyObject]) {
    guard let identifier = json["identifier"] as? String,
      remoteURI = json["remoteURI"] as? String
      else {
        fatalError("Identifier or remoteURI not found!")
    }
    
    self.identifier = identifier
    self.remoteURI = remoteURI
  }
  
  public func jsonRepresentation() -> [String : AnyObject] {
    var json = [
      "identifier": identifier
    ]
    
    if let uri = remoteURI { json["remoteURI"] = uri }
    return json
  }
  
}

public func ==(lhs: RemoteEntity, rhs: RemoteEntity) -> Bool {
  return lhs.identifier == rhs.identifier
}
