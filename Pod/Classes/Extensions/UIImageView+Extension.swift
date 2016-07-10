//
//  UIImageView+Extension.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import UIKit

public enum CacheAnimationStyle {
  case None
  case CrossDissolve
}

extension UIImageView {
  
  public func setCachedImage<E: EntityType>(cache: Cache<E, UIImage>, identifier: String, remoteURI: String, placeholderImage placeholder: UIImage? = nil, animationStyle animation: CacheAnimationStyle = .CrossDissolve) -> E? {
    updateImage(placeholder, placeholder: placeholder, withAnimationStyle: .None)
    
    guard let entity = cache.entities(identifier, autoCreate: true).first else { return nil }
    
    if let remote = entity as? RemoteEntity {
      remote.remoteURI = remoteURI
    }
  
    cache.fetchResourceForEntity(entity) { result in
      switch result {
      case .Success(let image) where entity.identifier == identifier:
        self.updateImage(image, placeholder: placeholder, withAnimationStyle: animation)
      case .Failure(let error):
        print(error)
        break
      default: break
      }
    }
    
    return entity
    
  }
  
  private func updateImage(image: UIImage?, placeholder: UIImage?, withAnimationStyle animation: CacheAnimationStyle) {
    if (image == nil || image == placeholder) && placeholder != nil {
      self.image = placeholder
      return
    }
    
    self.image = image
    guard animation != .None && self.image == nil else { return }
    
    switch animation {
    case .CrossDissolve:
      layer.addAnimation(CATransition(), forKey: "fade")
    case .None: break
    }
  }
  
}
