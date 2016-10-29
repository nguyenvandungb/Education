//
//  KanjiModel.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class KanjiModel: Object {
    dynamic var kId = ""
    dynamic var gId = ""
    dynamic var word = ""
    dynamic var time: Double = 0
    var paths = List<KanjiPathModel>()
    var texts = List<TextModel>()

    class func parseKanjiModel(xml: XMLElement, rootKey: String = "svg" ) -> KanjiModel? {
        if xml.name == rootKey {
            let kInfo = KanjiModel()
            kInfo.kId = xml.attributes["id"] ?? ""
            kInfo.time = NSDate().timeIntervalSince1970
            for gXML in xml.children {
                if gXML.isGroup() {
                    if kInfo.word.isEmpty {
                        kInfo.word = gXML.attributes["kvg:element"] ?? ""
                    }
                    if gXML.isText() {
                        for tXML in gXML.children {
                            if tXML.isText() {
                                if let tModel = TextModel.parseTextModel(tXML) {
                                    kInfo.texts.append(tModel)
                                }
                            }
                        }
                    } else {
                        kInfo.parsePathFromGroup(gXML)
                    }
                }
            }
            return kInfo
        }
        return nil
    }

    func parsePathFromGroup(gXML: XMLElement) {
        for pXML in gXML.children {
            if pXML.isPath() {
                if let pInfo = KanjiPathModel.parsePathModel(pXML) {
                    self.paths.append(pInfo)
                }
            } else {
                if self.word.isEmpty {
                    self.word = gXML.attributes["kvg:element"] ?? ""
                }
                if pXML.isGroup() {
                    parsePathFromGroup(pXML)
                }
            }
        }
    }

    func bezierPaths() -> [UIBezierPath] {
        var paths = [UIBezierPath]()
        for pInfo in self.paths {
            if let bzPath = pInfo.bezierPath() {
                paths.append(bzPath)
            }
        }
        return paths
    }
}
