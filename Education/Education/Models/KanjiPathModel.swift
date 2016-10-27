
//
//  KanjiPathModel.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift

class KanjiPathModel: Object {
    dynamic var pathId = ""
    dynamic var drawPath = ""
    let owners = LinkingObjects(fromType: KanjiGraphModel.self, property: "paths")
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
