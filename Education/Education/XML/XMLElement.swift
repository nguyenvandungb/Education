//
//  XMLElement.swift
//  kids_taxi
//
//  Created by Nguyen Van Dung on 3/15/16.
//  Copyright © 2016 JapanTaxi. All rights reserved.
//

import Foundation
public class XMLElement: NSObject {
    //XMLDocument will has parent = nil
    weak var parent: XMLElement?
    public var children: [XMLElement] = [XMLElement]()
    
    //XML element name. Default is empty
    public var name: String
    
    //XML value. Default is empty
    public var value: String?
    
    //Attribute. Default is empty
    public var attributes: [String : String]
    
    public static let errorElementName = "AEXMLError"
    
    public override init() {
        self.name = ""
        attributes = [String : String]()
        super.init()
    }
    
    public convenience init(name: String?, value: String?, attributes: [String : String]?) {
        self.init()
        self.name = name ?? ""
        self.value = value
        self.attributes = attributes ?? [String : String]()
    }
    
    public var all: [XMLElement]? {
        get {
            return parent?.children.filter {$0.name == self.name}
        }
    }
    
    public var first: XMLElement? {
        get {
            return all?.first
        }
    }
    
    public var last: XMLElement? {
        get {
            return all?.last
        }
    }
    
    public var count: Int {
        get {
            return all?.count ?? 0
        }
    }
    
    public func addChild(child: XMLElement) -> XMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    private func removeChild(child: XMLElement) {
        if let childIndex = children.indexOf(child) {
            children.removeAtIndex(childIndex)
        }
    }
    
    public func removeFromParent() {
        parent?.removeChild(self)
    }
    
    public var parentsCount: Int {
        var count = 0
        var element = self
        while let parent = element.parent {
            count += 1
            element = parent
        }
        return count
    }
    
    private func indentation(count: Int) -> String {
        var countDown = count
        var indent = String()
        while countDown > 0 {
            indent += "\t"
            countDown -= 1
        }
        return indent
    }
    
    public var stringValue: String { return value ?? String() }
    
    public var escapedStringValue: String {
        var escapedString = stringValue.stringByReplacingOccurrencesOfString("&", withString: "&amp;", options: .LiteralSearch)
        let escapeChars = ["<" : "&lt;", ">" : "&gt;", "'" : "&apos;", "\"" : "&quot;"]
        
        for (char, echar) in escapeChars {
            escapedString = escapedString.stringByReplacingOccurrencesOfString(char, withString: echar, options: .LiteralSearch)
        }
        
        return escapedString
    }
    
    public var xmlString: String {
        var xml = String()
        // open element
        xml += indentation(parentsCount - 1)
        xml += "<\(name)"
        if attributes.count > 0 {
            // insert attributes
            for (key, value) in attributes {
                xml += " \(key)=\"\(value)\""
            }
        }
        
        if value == nil && children.count == 0 {
            // close element
            xml += " />"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child.xmlString)\n"
                }
                // add indentation
                xml += indentation(parentsCount - 1)
                xml += "</\(name)>"
            } else {
                // insert string value and close element
                xml += ">\(escapedStringValue)</\(name)>"
            }
        }
        return xml
    }
    
    public func getValueForKey(key: String) -> XMLElement {
        if name == XMLElement.errorElementName {
            return self
        } else {
            let filtered = children.filter { $0.name == key }
            let errorElement = XMLElement(name: XMLElement.errorElementName, value: "element <\(key)> not found", attributes: nil)
            return filtered.count > 0 ? filtered.first! : errorElement
        }        
    }
}
