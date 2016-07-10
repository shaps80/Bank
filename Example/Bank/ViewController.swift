//
//  ViewController.swift
//  Bank
//
//  Created by Shaps on 07/07/2016.
//  Copyright (c) 2016 Shaps. All rights reserved.
//

import UIKit
import LoremIpsum
import Bank

class ViewController: UIViewController, UITableViewDataSource {
  
  @IBOutlet var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    if Caches.peopleCache().allEntities().count == 0 {
      prepareDataSource()
    }
  }

  func prepareDataSource() {
    for _ in 0..<50 {
      let entity = Entity()

      var person = Person(id: entity.identifier)
      person.name = LoremIpsum.name()
      person.age = Int(arc4random_uniform(35) + 18)

      let cache = Caches.peopleCache()
      try! cache.addEntity(entity, person)
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
    let entity = Caches.peopleCache().allEntities()[indexPath.item]
    
    Caches.peopleCache().fetchResourceForEntity(entity) { (result) in
      switch result {
      case .Success(let person):
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = "\(person.age)"
        cell.imageView?.setCachedImage(Caches.imageCache(), identifier: "1234", remoteURI: "http://lorempixel.com/g/400/400/")
      case .Failure(let error):
        print(error)
      }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Caches.peopleCache().allEntities().count
  }
  
}

