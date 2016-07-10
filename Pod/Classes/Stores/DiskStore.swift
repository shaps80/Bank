//
//  DiskStore.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public final class DiskStore: WritableStore, DeletableStore {
  
  private static var DefaultPath: String {
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! as NSString
    return caches.stringByAppendingPathComponent("")
  }
  
  private static var ioQueue: dispatch_queue_t = dispatch_queue_create("bank.cache.diskstore.queue.io", DISPATCH_QUEUE_SERIAL)
  private var localPath: String
  private var name: String
  
  lazy private var transformQueue: dispatch_queue_t = {
    let name = "bank.cache.diskstore.queue.transform"
    return dispatch_queue_create(name, DISPATCH_QUEUE_CONCURRENT)
  }()
  
  private func pathForEntity<E: EntityType>(entity: E) -> String {
    let rootPath = localPath as NSString
    return rootPath.stringByAppendingPathComponent(entity.identifier + ".resource")
  }
  
  public init(name: String, localPath: String? = nil) {
    self.localPath = localPath ?? NSString(string: DiskStore.DefaultPath).stringByAppendingPathComponent(name)
    self.name = name
  }
  
  public func canFulfillFetch<E : EntityType>(for entity: E) -> Bool {
    return NSFileManager.defaultManager().fileExistsAtPath(pathForEntity(entity))
  }
  
  public func read<E : EntityType, T : Resource>(for entity: E, completion: CacheFetchResult<T> -> Void) {
    Queue(queue: DiskStore.ioQueue).async { [unowned self] in
      do {
        let data = try NSData(contentsOfFile: self.pathForEntity(entity), options: [])
        if let resource = T(data: data) {
          completion(.Success(resource))
        } else {
          completion(.Failure(nil))
        }
      } catch let error {
        completion(.Failure(.InvalidData))
      }
    }
  }
  
  public func write<E : EntityType, T : Resource>(for entity: E, resource: T, completion: CacheFetchResult<T> -> Void) {
    Queue(queue: DiskStore.ioQueue).async {
      if !NSFileManager.defaultManager().fileExistsAtPath(self.localPath) {
        try! NSFileManager.defaultManager().createDirectoryAtPath(self.localPath, withIntermediateDirectories: true, attributes: nil)
      }
      
      do {
        try resource.dataRepresentation().writeToFile(self.pathForEntity(entity), options: .DataWritingAtomic)
        completion(.Success(resource))
      } catch {
        completion(.Failure(.FailedToWriteResource))
      }
    }
  }
  
  public func delete<E : EntityType>(for entity: E) {
    Queue(queue: DiskStore.ioQueue).async {
      do {
        try NSFileManager.defaultManager().removeItemAtPath(self.pathForEntity(entity))
      } catch let error as NSError {
        print(error)
      }
    }
  }
  
  public func deleteAll() {
    Queue(queue: DiskStore.ioQueue).async {
      do {
        try NSFileManager.defaultManager().removeItemAtPath(self.localPath)
      } catch { }
    }
  }
  
}
