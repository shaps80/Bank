//
//  Cache.swift
//  Bank
//
//  Created by Shaps Mohsenin on 10/01/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Bank

class Client: RemoteStoreDelegate {
  
  static var sharedClient = {
    return Client()
  }()
  
  func store<E : RemoteEntity>(store: RemoteStore, fetchResourceForEntity entity: E, completion: CacheFetchResult<NSData> -> Void) {
    guard let uri = entity.remoteURI, url = NSURL(string: uri) else {
      completion(.Failure(nil))
      return
    }
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
      if let d = data {
        completion(CacheFetchResult.Success(d))
      } else {
        completion(CacheFetchResult.Failure(error))
      }
    }
    
    task.resume()
  }
  
  func store<E : RemoteEntity>(store: RemoteStore, cancelFetchForEntity entity: E) {
    
  }
  
}

class Caches {
  
  static func imageCache() -> Cache<RemoteEntity, UIImage> {
    return _imageCache
  }
  
  static func peopleCache() -> Cache<Entity, Person> {
    return _peopleCache
  }
  
  private static var _imageCache: Cache<RemoteEntity, UIImage> = {
    let disk = DiskStore(name: "Disk")
    let memory = MemoryStore()
    let remote = RemoteStore(delegate: Client.sharedClient)
    return Cache<RemoteEntity, UIImage>(name: "Images", stores: memory, disk, remote)
  }()
  
  private static var _peopleCache: Cache<Entity, Person> = {
    return Cache<Entity, Person>(name: "People", stores: MemoryStore())
  }()
  
}
