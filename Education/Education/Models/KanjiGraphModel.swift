//
//  KanjiGraphModel.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift

class KanjiGraphModel: Object {
    dynamic var gId = ""
    var paths = List<KanjiPathModel>()
    var owners = LinkingObjects(fromType: KanjiModel.self, property: "graphs")
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
