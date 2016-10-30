
//
//  KanjiPathModel.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift
import SVGgh

class KanjiPathModel: Object {
    dynamic var pathId = ""
    dynamic var drawPath = ""
    dynamic var type = ""
    dynamic var time: Double = 0
    class func parsePathModel(xml: XMLElement) -> KanjiPathModel? {
        if xml.name == "path" {
            let pInfo = KanjiPathModel()
            pInfo.pathId = xml.attributes["id"] ?? ""
            pInfo.type = xml.attributes["kvg:type"] ?? ""
            pInfo.drawPath = xml.attributes["d"] ?? ""
            pInfo.time = NSDate().timeIntervalSince1970
            return pInfo
        }
        return nil
    }

    func bezierPath() -> UIBezierPath? {
        if drawPath.characters.count > 0 {
            let bezierPath =  DhtSVGParser(SVGPathStr: self.drawPath).parse()
            bezierPath.miterLimit = 4;
            bezierPath.lineCapStyle = .Round;
            bezierPath.lineJoinStyle = .Round;
            bezierPath.lineWidth = 2.5
            return bezierPath
        }
        return nil
    }
}
