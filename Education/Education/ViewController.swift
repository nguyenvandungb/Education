//
//  ViewController.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/27/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    lazy var categories: Results<Category> = { RealmManager.shareInstance.realm.objects(Category) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(Realm.Configuration.defaultConfiguration.description)
        importKanjiDatToDatabase()
    }

    func testRealm() {
        if categories.count == 10 {
            let realm = RealmManager.shareInstance.realm
            do {
                try realm.write({
                    let defaultCategories = ["Birds", "Mammals", "Flora", "Reptiles", "Arachnids" ]
                    for category in defaultCategories { // 4
                        let newCategory = Category()
                        newCategory.name = category
                        realm.add(newCategory)
                    }
                })
            } catch  {
                print("write transaction error")
            }
            categories = RealmManager.shareInstance.realm.objects(Category) // 5
        }
        print("====> \(categories.count)")
    }

    func importKanjiDatToDatabase() {
        if let path = NSBundle.mainBundle().pathForResource("kanjivg", ofType: "xml") {
            ImportDataManager.instance.importKanjiXMLFile(path)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

