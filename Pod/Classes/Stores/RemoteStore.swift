//
//  RemoteStore.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

public protocol RemoteStoreDelegate: class {
  func store<E: RemoteEntity>(store: RemoteStore, fetchResourceForEntity entity: E, completion: CacheFetchResult<NSData> -> Void)
  func store<E: RemoteEntity>(store: RemoteStore, cancelFetchForEntity entity: E)
}

public final class RemoteStore: ReadableStore, CancelableStore {
  
  private weak var delegate: RemoteStoreDelegate?
  
  public init(delegate: RemoteStoreDelegate) {
    self.delegate = delegate
  }
  
  public func canFulfillFetch<E : EntityType>(for entity: E) -> Bool {
    return true
  }
  
  public func read<E : EntityType, T : Resource>(for entity: E, completion: CacheFetchResult<T> -> Void) {
    guard let remoteEntity = entity as? RemoteEntity else {
      print(NSError(domain: "uk.co.snippex.ios.bank", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bank: Invalid entity type '\(entity)'"]))
      return
    }
    
    delegate?.store(self, fetchResourceForEntity: remoteEntity) { result in
      switch result {
      case .Success(let data):
        if let resource = T(data: data) {
          completion(.Success(resource))
        } else {
          completion(.Failure(nil))
        }
      case .Failure(let error):
        completion(.Failure(error))
      }
    }
  }
  
  public func cancelFetch<E : EntityType>(for entity: E) {
    guard let remoteEntity = entity as? RemoteEntity else {
      print(NSError(domain: "uk.co.snippex.ios.bank", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bank: Invalid entity type '\(entity)'"]))
      return
    }
    
    delegate?.store(self, cancelFetchForEntity: remoteEntity)
  }
  
}

