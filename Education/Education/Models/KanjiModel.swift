//
//  KanjiModel.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift

class KanjiModel: Object {
    dynamic var kId = ""
    dynamic var gId = ""
    var graphs = List<KanjiGraphModel>()
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
