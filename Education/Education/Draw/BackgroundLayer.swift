//
//  BackgroundLayer.swift
//  Pods
//
//  Created by Andriy K. on 12/28/15.
//
//

import UIKit
import RealmSwift

class BackgroundLayer: CALayer {

    var strokes: [UIBezierPath]?
    var texts = List<TextModel>()
    var strokeColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 0.5)

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(layer: AnyObject) {
        super.init(layer: layer)
    }

    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)

        guard let strokes = strokes else { return }

    
        for stroke in strokes {
            CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor)
            CGContextSetLineWidth(ctx, stroke.lineWidth - 1)
            CGContextAddPath(ctx, stroke.CGPath)
            CGContextDrawPath(ctx, .Stroke)
        }
        
    }

}
