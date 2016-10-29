//
//  UIScrollView+Extension.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/30/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func screenShot() -> UIImage? {
        self.contentOffset = CGPoint.zero
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(self.contentSize, true, 2.0)
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame
        self.contentOffset = CGPoint.zero
        self.frame = CGRect(origin: CGPoint.zero, size: self.contentSize)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext();
        self.contentOffset = savedContentOffset
        self.frame = savedFrame
        UIGraphicsEndImageContext()
        return image
    }
}
