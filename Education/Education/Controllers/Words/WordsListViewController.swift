//
//  WordsListViewController.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class WordsListViewController: UITableViewController {

    lazy var dataSource: Results<KanjiModel> = {

        return RealmManager.shareInstance.realm.objects(KanjiModel.self)
    }();

    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.description)
       importKanjiDatToDatabase()
    }

    func importKanjiDatToDatabase() {
        if dataSource.count == 0 {
            if let path = NSBundle.mainBundle().pathForResource("kanjivg", ofType: "xml") {
                ImportDataManager.instance.importKanjiXMLFile(path)
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("WordCell") as? WordCell {
            let info = dataSource[indexPath.row]
            cell.wordLabel?.text = info.word
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let info = dataSource[indexPath.row]
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DrawViewController") as? DrawViewController {
            controller.word = info.word
            controller.bezierPaths = info.bezierPaths()
            controller.info = info
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
