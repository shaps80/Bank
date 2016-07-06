//
//  Queue.swift
//  Reel
//
//  Created by Shaps Mohsenin on 06/07/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import Foundation

/**
 *  Simple GCD Wrapper
 */
public struct Queue {
  
  public typealias TimeInterval = NSTimeInterval
  
  public static let Main = Queue(queue: dispatch_get_main_queue());
  public static let Default = Queue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
  public static let Background = Queue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
  public static let High = Queue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
  public static let Low = Queue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))
  
  public private(set) var queue: dispatch_queue_t
  
  public init(queue: dispatch_queue_t = dispatch_queue_create(NSBundle.mainBundle().bundleIdentifier! + ".queue", DISPATCH_QUEUE_SERIAL)) {
    self.queue = queue
  }
  
  public func after(interval: NSTimeInterval, block: () -> Void) {
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * NSTimeInterval(NSEC_PER_SEC)))
    dispatch_after(dispatchTime, queue, block)
  }
  
  public func async(block: () -> Void) {
    dispatch_async(queue, block)
  }
  
  public func sync(block: () -> Void) {
    dispatch_sync(queue, block)
  }
}
