//
//  ImageMemoryStore.swift
//  Pods
//
//  Created by Shaps Mohsenin on 10/07/2016.
//
//

import Foundation

public final class ImageMemoryStore: WritableStore, DeletableStore, FaultableStore {
  
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
    guard let image = nsCache.objectForKey(entity.identifier) as? UIImage else {
      completion(.Failure(nil))
      return
    }
    
    let result = CacheFetchResult.Success(image) as! CacheFetchResult<T>
    completion(result)
  }
  
  public func write<E : EntityType, T : Resource>(for entity: E, resource: T, completion: CacheFetchResult<T> -> Void) {
    if let image = resource as? UIImage {
      Queue.High.async {
        let decompressed = image.decompressedImage()
        self.nsCache.setObject(image, forKey: entity.identifier)
        completion(.Success(resource))
      }
    }
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

