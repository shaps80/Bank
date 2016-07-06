//
//  UIImage+Extensions.swift
//  Bank
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

extension UIImage: Resource {
  
  public func dataRepresentation() -> NSData {
    return UIImageJPEGRepresentation(self, 0.8)!
  }
  
}

