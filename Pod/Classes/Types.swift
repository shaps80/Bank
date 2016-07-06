//
//  Types.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public enum CacheError: ErrorType {
  case MissingEntity
  case DuplicateEntity
}

public enum CacheFetchResult<T: Resource> {
  
  case Success(T)
  case Failure(NSError?)
  
}

public protocol Resource {
  init?(data: NSData)
  func dataRepresentation() -> NSData
}

