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

extension UIImage {
  
  public func decompressedImage(scale scale: CGFloat = UIScreen.mainScreen().scale) -> UIImage? {
    let imageRef = self.CGImage
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
    let contextHolder = UnsafeMutablePointer<Void>(nil)
    let context = CGBitmapContextCreate(contextHolder, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 0, colorSpace, bitmapInfo)
    if let context = context {
      let rect = CGRect(x: 0, y: 0, width: CGImageGetWidth(imageRef), height: CGImageGetHeight(imageRef))
      CGContextDrawImage(context, rect, imageRef)
      let decompressedImageRef = CGBitmapContextCreateImage(context)
      return DecompressedImage(CGImage: decompressedImageRef!, scale: scale, orientation: self.imageOrientation)
    } else {
      return nil
    }
  }
  
  public func resizedImage(size: CGSize, opaque: Bool = true, scale: CGFloat = UIScreen.mainScreen().scale) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
    drawInRect(CGRect(origin: CGPointZero, size: size))
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
}
