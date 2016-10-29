//
//  TextModel.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/29/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift

public class TextModel: Object {
    
    dynamic var value = ""
    dynamic var matrix = ""
    dynamic var time: Double = 0
    var origin = CGPoint.zero

    override public static func ignoredProperties() -> [String] {
        return ["origin"]
    }
    class func parseTextModel(xml: XMLElement) -> TextModel? {
        if xml.name == "text" {
            let tInfo = TextModel()
            if let xmlattr = xml.attributes["transform"] {
                tInfo.matrix = xmlattr
            }
            tInfo.value = xml.value ?? ""
            tInfo.time = NSDate().timeIntervalSince1970
            return tInfo
        }
        return nil
    }

    func calculateorigin(fromOrigin: CGPoint) -> CGPoint {
        print(fromOrigin)
        var substr = matrix.stringByReplacingOccurrencesOfString("matrix(", withString: "")
        substr = substr.stringByReplacingOccurrencesOfString(")", withString: "")
        let arr = substr.componentsSeparatedByString(" ")
        if arr.count >= 2{
            var point = CGPoint.zero
            var str = arr[arr.count - 1]
            point.y = CGFloat(Double(str) ?? 0) ?? 0
            str = arr[arr.count - 2]
            point.x = CGFloat(Double(str) ?? 0) ?? 0
            origin = point
            return point
        }
        return CGPoint.zero
    }
}
