//
//  RealmManager.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager: NSObject {
    let realm = try! Realm()
    static let shareInstance = RealmManager()

    func write(constructor: () -> ()) {
        realm.beginWrite()
    }
}
