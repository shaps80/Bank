//
//  MemoryStore.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public final class MemoryStore: WritableStore, DeletableStore, FaultableStore {
  
  private var nsCache = NSCache()
  
  public required init() { }
  
  public required init(countLimit limit: Int?) {
    if let value = limit {
      nsCache.countLimit = value
    }
  }
  
  public required init(costLimit limit: Int?) {
    if let value = limit {
      nsCache.totalCostLimit = value
    }
  }
  
  public func canFulfillFetch<E : EntityType>(for entity: E) -> Bool {
    return nsCache.objectForKey(entity.identifier) != nil
  }
  
  public func read<E : EntityType, T : Resource>(for entity: E, completion: CacheFetchResult<T> -> Void) {
    guard let data = nsCache.objectForKey(entity.identifier) as? NSData,
      resource = T(data: data) else {
        completion(.Failure(nil))
        return
    }
    
    completion(.Success(resource))
  }
  
  public func write<E : EntityType, T : Resource>(for entity: E, resource: T, completion: CacheFetchResult<T> -> Void) {
    nsCache.setObject(resource.dataRepresentation(), forKey: entity.identifier)
    completion(.Success(resource))
  }
  
  public func delete<E : EntityType>(for entity: E) {
    nsCache.removeObjectForKey(entity.identifier)
  }
  
  public func deleteAll() {
    nsCache.removeAllObjects()
  }
  
  public func fault<E : EntityType>(for entity: E) {
    delete(for: entity)
  }
  
  public func faultAll() {
    nsCache.removeAllObjects()
  }
  
}
