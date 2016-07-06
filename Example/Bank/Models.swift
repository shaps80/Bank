//
//  Renders.swift
//  Bank
//
//  Created by Shaps Mohsenin on 10/01/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Bank

struct Person {
  
  let id: String
  var name: String = "Shaps"
  var age: Int = 21
  
  init(id: String = NSUUID().UUIDString) {
    self.id = id
  }
  
}

extension Person: Resource {
  
  init(data: NSData) {
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
      let id = json["id"] as! String

      self.init(id: id)
      name = json["name"] as! String
      age = json["age"] as! Int
    } catch { fatalError() }
  }
  
  func dataRepresentation() -> NSData {
    do {
      let json = [
        "id": id,
        "name": name,
        "age": age
        ]
      
      return try NSJSONSerialization.dataWithJSONObject(json, options: [])
    } catch { fatalError() }
  }
  
}
