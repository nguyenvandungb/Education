//
//  String+Extension.swift
//  kids_taxi
//
//  Created by Nguyen Van Dung on 3/14/16.
//  Copyright © 2016 JapanTaxi. All rights reserved.
//

import Foundation

public extension String {
    func stringFromIndex(index: Int) -> String {
        return self.substringFromIndex(self.endIndex.advancedBy(index))
    }
    
    func stringToIndex(index: Int) -> String {
        return self.substringToIndex(self.startIndex.advancedBy(index))
    }
    
    func length() -> Int {
        return self.characters.count
    }
    
    func base64String() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) ?? self
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(path)
    }
    
    func trimSpaceAndNewLine() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func attributeText(lineSpacing lineSpacing: CGFloat, align: NSTextAlignment = NSTextAlignment.Left) -> NSMutableAttributedString {
        var temp = self
        if temp.length() > 0 {
            temp = temp.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let muatableString  = NSMutableAttributedString(string: temp)
            let paragrahStyle = NSMutableParagraphStyle()
            paragrahStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            paragrahStyle.lineSpacing = lineSpacing
            paragrahStyle.alignment = align
            muatableString.addAttribute(NSParagraphStyleAttributeName, value: paragrahStyle, range: _NSRange(location: 0, length: temp.length()))
            return muatableString
        }
        return NSMutableAttributedString()
    }
    
    func isValidForUrl() -> Bool {
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        return predicate.evaluateWithObject(self)
    }
}
