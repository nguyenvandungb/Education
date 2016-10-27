//
//  TestReaml.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift

class TestReaml: Object {
    dynamic var name = ""
    dynamic var specimenDescription = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var created = NSDate()
    dynamic var category: Category!
}
