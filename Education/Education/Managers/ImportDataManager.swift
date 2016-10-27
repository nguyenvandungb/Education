//
//  ImportDataManager.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation

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
                            let kInfo = KanjiModel()
                            if let kId =  kanjiXML.attributes["id"] {
                                kInfo.kId = kId
                            }

                            for graph in kanjiXML.children {
                                let gObj = KanjiGraphModel()
                                if let gId = graph.attributes["id"] {
                                    gObj.gId = gId
                                }

                                for path in graph.children {
                                    let pInfo = KanjiPathModel()
                                    if let pId = path.attributes["id"] {
                                        pInfo.pathId = pId
                                    }
                                    if let drawPath = path.attributes["d"] {
                                        pInfo.drawPath = drawPath
                                    }
                                    //add to graph model
                                    gObj.paths.append(pInfo)
                                }
                                //add graph model
                                kInfo.graphs.append(gObj)
                            }
                            listKanjis.append(kInfo)
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
