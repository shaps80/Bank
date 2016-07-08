//
//  Cache.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public final class Cache<E: EntityType, T: Resource>: CustomStringConvertible {
  
  public let name: String
  private let stores: [ReadableStore]
  
  public var description: String {
    return
      "Name:  \(name)\n" +
      "Path:  \(Cache.pathForEntities(name))"
  }
  
  /// All entities associated with this cache
  private var entities = Set<E>()
  
  public init(name: String, stores: ReadableStore...) {
    precondition(stores.count > 0)
    
    self.name = name
    self.stores = stores
    
    loadEntities()
    cleanup()
  }
  
  // this function will iterate over all entities and ensure the resource can still be fulfilled, otherwise it will cleanup and remove the entity completely to avoid null references
  private func cleanup() {
    for entity in entities {
      var canFulfill = false
      
      for store in stores {
        if store.canFulfillFetch(for: entity) {
          canFulfill = true
        }
      }
      
      if !canFulfill {
        entities.remove(entity)
      }
    }
    
    saveChanges()
  }
  
  private func loadEntities() {
    guard NSFileManager.defaultManager().fileExistsAtPath(Cache.pathForEntities(name)),
    let data = NSData(contentsOfFile: Cache.pathForEntities(name)) else { return }
    
    do {
      guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]] else { return }
      
      for obj in json {
        let entity = E(jsonRepresentation: obj)
        entities.insert(entity)
      }
    } catch {
      fatalError()
    }
  }
  
  /**
   Adds the specified Entity to this cache
   
   - parameter entity:   The entity to add
   - parameter resource: The associated resource for this entity, can be nil
   
   - throws: If the entity already exists in the cache, a CacheError.DuplicateEntity exception will be thrown
   */
  public final func addEntity(entity: E, _ resource: T? = nil) throws {
    guard !entities.contains(entity) else {
      throw CacheError.DuplicateEntity
    }
    
    entities.insert(entity)
    try setResource(resource, forEntity: entity)
    
    saveChanges()
  }
  
  /**
   Removes the specified entity from this cache
   
   - parameter entity: The entity to delete
   */
  public final func removeEntity(entity: E) {
    guard let index = entities.indexOf(entity) else {
      return
    }
    
    for store in stores {
      if let deletableStore = store as? DeletableStore {
        deletableStore.delete(for: entity)
      }
    }
    
    entities.removeAtIndex(index)
    saveChanges()
  }
  
  /**
   Performs a query on the cache
   
   - parameter query: The query to perform
   
   - returns: If Entities were found matching the query they will be returned. If not, an empty array will be returned
   */
  public final func entities(identifiers: String..., autoCreate: Bool = false) -> [E] {
    var localEntities: [E] = self.entities.filter({ identifiers.contains($0.identifier) })
    let existingIdentifiers: [String] = localEntities.map({ return $0.identifier })
    
    if localEntities.count != identifiers.count && autoCreate {
      let missingIdentifiers = identifiers.filter({ !existingIdentifiers.contains($0) })
      
      for identifier in missingIdentifiers {
        let entity = E(identifier: identifier)
        
        localEntities.append(entity) // add to our results array
        self.entities.insert(entity) // add to our global entities
      }
    }
    
    saveChanges()
    return localEntities
  }
  
  /**
   Sets the specified resource for the given entity. If a resource was previously set, this will override it and update all stores. If the entity doesn't belong to this cache a CacheError.EntityDoesntExist exception will be thrown
   
   - parameter resource: The resource to associate with this entity
   - parameter entity:   The entity to associate with this resource
   */
  public final func setResource(resource: T? = nil, forEntity entity: E) throws {
    guard entities.contains(entity) else {
      throw CacheError.MissingEntity
    }
    
    for store in stores {
      if let writableStore = store as? WritableStore, res = resource {
        writableStore.write(for: entity, resource: res)
      }
    }
  }
  
  /**
   Fetches the resource for the specified entity
   
   - parameter entity:     The entity representing this resource
   - parameter completion: The completion block to execute when this resource has been fetched
   */
  public final func fetchResourceForEntity(entity: E, completion: CacheFetchResult<T> -> Void) {
    var resourceToPropagate: T?
    
    for store in stores {
      if !store.canFulfillFetch(for: entity) {
        continue
      }
      
      store.read(for: entity) { (result: CacheFetchResult<T>) in
        switch result {
        case .Success(let resource):
          resourceToPropagate = resource
          completion(CacheFetchResult.Success(resource))
        case .Failure(let error):
          completion(CacheFetchResult.Failure(error))
        }
      }
      
      break
    }
    
    if let resource = resourceToPropagate {
      let stores = self.stores.flatMap { $0 as? WritableStore }
      stores.forEach { $0.write(for: entity, resource: resource) }
    }
  }
  
  /**
   Cancels the current fetch request (if any) for the specified Entity
   
   - parameter entity: The entity to cancel
   */
  public final func cancelFetchForEntity(entity: E) {
    for store in stores {
      if let cancelableStore = store as? CancelableStore {
        cancelableStore.cancelFetch(for: entity)
      }
    }
  }
  
  /**
   Returns all entities associated with this cache
   
   - returns: All cache entities
   */
  public func allEntities() -> [E] {
    return Array(entities)
  }
  
  /**
   Saves any changes -- this is called automatically when you add/remove entities, however if you modify an Entity directly you will need to call this method in order to persist any changes
   */
  public final func saveChanges() {
    var json = [[String: AnyObject]]()
    
    for entity in entities {
      json.append(entity.jsonRepresentation())
    }
    
    do {
      let data = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
      try data.writeToFile(Cache.pathForEntities(name), options: .DataWritingAtomic)
    } catch {
      fatalError()
    }
  }
  
  // MARK: Private functions
  
  // Returns the path where the entities data will be stores -- $HOME/Documents/$CACHE_NAME.entities
  private static func pathForEntities(name: String) -> String {
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    return NSString(string: path).stringByAppendingPathComponent("\(name).entities")
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // When a memory warning is detected, the cache will automatically call faultAll() on any FaultableStore's
  @objc private func memoryWarning() {
    for store in stores {
      if let faultableStore = store as? FaultableStore {
        faultableStore.faultAll()
      }
    }
  }
  
}
