//
//  KanjiGraphModel.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift

class KanjiGroupModel: Object {
    dynamic var gId = ""
    dynamic var element = ""
    dynamic var time: Double = 0
    var paths = List<KanjiPathModel>()
    dynamic var owner: KanjiModel?
    var groups = List<KanjiGroupModel>()

    class func parseGroupModel(xml: XMLElement, parent: KanjiModel) -> KanjiGroupModel? {
        if xml.name == "g" {
            let element = xml.attributes["kvg:element"]
            let gInfo = KanjiGroupModel()
            gInfo.gId = xml.attributes["id"] ?? ""
            gInfo.element = element ?? ""
            gInfo.time = NSDate().timeIntervalSince1970
            for pXML in xml.children {
                if pXML.isPath() {
                    if let pInfo = KanjiPathModel.parsePathModel(pXML) {
                        gInfo.paths.append(pInfo)
                    }
                } else {
                    if pXML.isGroup() {
                        if let gInfoChild = KanjiGroupModel.parseGroupModel(pXML, parent: parent) {
                            gInfo.groups.append(gInfoChild)
                            gInfo.owner = parent
                        }
                    }
                }
            }
            return gInfo
        }
        return nil
    }

    func allPathInfo() -> [KanjiPathModel] {
        var results = [KanjiPathModel]()
        for pModel in paths {
            results.append(pModel)
        }
        for gInfo in groups {
            results.appendContentsOf(gInfo.allPathInfo())
        }
        return results
    }

    func bezierPaths() -> [UIBezierPath] {
        var results = [UIBezierPath]()
        paths.sorted("time", ascending: true)
        for pModel in paths {
            if let bzPath = pModel.bezierPath() {
                results.append(bzPath)
            }
        }
        groups.sorted("time", ascending: true)
        for gInfo in groups {
            results.appendContentsOf(gInfo.bezierPaths())
        }
        return results
    }
}
