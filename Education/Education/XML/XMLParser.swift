//
//  XMLParser.swift
//  kids_taxi
//
//  Created by Nguyen Van Dung on 3/15/16.
//  Copyright © 2016 JapanTaxi. All rights reserved.
//

import Foundation
class XMLParser: NSObject, NSXMLParserDelegate {
   
    let xmlDocument: XMLDocument
    let xmlData: NSData
    var currentParent: XMLElement?
    var currentElement: XMLElement?
    var currentValue = String()
    var parseError: NSError?

    
    init(xmlDocument: XMLDocument, xmlData: NSData) {
        self.xmlDocument = xmlDocument
        self.xmlData = xmlData
        currentParent = xmlDocument
        super.init()
    }
    
    func parse() throws {
        let parser = NSXMLParser(data: xmlData)
        parser.delegate = self
        
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        
        let success = parser.parse()
        if !success {
            throw parseError ?? NSError(domain: "", code: 1, userInfo: nil)
        }
    }
    
    @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentValue = String()
        let child: XMLElement = XMLElement(name: elementName, value: nil, attributes: attributeDict)
        currentElement = currentParent?.addChild(child)
        currentParent = currentElement
    }
    
    @objc func parser(parser: NSXMLParser, foundCharacters string: String) {
        currentValue += string
        let newValue = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        currentElement?.value = newValue == String() ? nil : newValue
    }
    
    @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentParent = currentParent?.parent
        currentElement = nil
    }
    
    @objc func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        self.parseError = parseError
    }
}