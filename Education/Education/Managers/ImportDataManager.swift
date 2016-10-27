//
//  ImportDataManager.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation

//Kanji data supporter
extension XMLElement {
    func isGroup() -> Bool {
        if self.name == "g" {
            return true
        }
        return false
    }

    func isText() -> Bool {
        if self.name == "text" {
            return true
        }
        for xml in self.children {
            if xml.name == "text" {
                return true
            }
        }
        return false
    }

    func isPath() -> Bool {
        if self.name == "path" {
            return true
        }
        return false
    }
}

class ImportDataManager: NSObject {
    static let instance = ImportDataManager()

    func importKanjiXMLFile(filePath: String?) {
        guard let path = filePath else {
            return
        }

        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            return
        }
        if let xmlData = NSData(contentsOfFile: path) {
            do {
                let xmlDoc = try XMLDocument(xmlData: xmlData)
                if let root = xmlDoc.children.first {
                    if root.name != XMLDocument.errorElementName {
                        var listKanjis = [KanjiModel]()
                        for kanjiXML in root.children {
                            if let kInfo = KanjiModel.parseKanjiModel(kanjiXML) {
                                listKanjis.append(kInfo)
                            }
                        }
                        //realm add kanji model
                        if listKanjis.count > 0 {
                            let realm = RealmManager.shareInstance.realm
                            try! realm.write({
                                for info in listKanjis {
                                    realm.add(info)
                                }
                            })
                        }
                    }
                }
            } catch  {
                print("Content of \(path) is empty")
            }
        }
    }
}
