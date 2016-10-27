//
//  XMLDocument.swift
//  kids_taxi
//
//  Created by Nguyen Van Dung on 3/15/16.
//  Copyright © 2016 JapanTaxi. All rights reserved.
//

import Foundation
public class XMLDocument: XMLElement {
    
    private struct Defaults {
        static let version = 1.0
        static let encoding = "utf-8"
        static let standalone = "no"
        static let documentName = "XMLDocument"
    }

    private let errorElement = XMLElement(name: XMLElement.errorElementName, value: "XML Document must have root element.", attributes: nil)
    
    public var root: XMLElement {
        return children.count == 1 ? children.first! : errorElement
    }
    
    public convenience init(root: XMLDocument? ) {
        self.init(name: Defaults.documentName, value: nil, attributes: nil)
        parent = nil
        if let rootElement = root {
            addChild(rootElement)
        }
    }
    
    public convenience init(xmlData: NSData) throws {
        self.init(root: nil)
        try loadXMLData(xmlData)
    }
    
    public func loadXMLData(data: NSData) throws {
        children.removeAll(keepCapacity: false)
        let xmlParser = XMLParser(xmlDocument: self, xmlData: data)
        try xmlParser.parse()
    }
}
