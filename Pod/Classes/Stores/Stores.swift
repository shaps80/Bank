//
//  Stores.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public protocol CacheStore: class {
  func canFulfillFetch<E: EntityType>(for entity: E) -> Bool
}

public protocol ReadableStore: CacheStore {
  func read<E: EntityType, T: Resource>(for entity: E, completion: CacheFetchResult<T> -> Void)
}

public protocol WritableStore: ReadableStore {
  func write<E: EntityType, T: Resource>(for entity: E, resource: T, completion: CacheFetchResult<T> -> Void)
}

public protocol DeletableStore: CacheStore {
  func delete<E: EntityType>(for entity: E)
  func deleteAll()
}

public protocol FaultableStore: CacheStore {
  func fault<E: EntityType>(for entity: E)
  func faultAll()
}

public protocol CancelableStore: CacheStore {
  func cancelFetch<E: EntityType>(for entity: E)
}
