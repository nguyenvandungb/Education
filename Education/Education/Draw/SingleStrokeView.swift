//
//  SingleStrokeView.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/30/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation

class SingleStrokeView: UIView {
    var shouldDraw = false
    private var backgroundLayer = BackgroundLayer()
    private var colorLayer = BackgroundLayer()
    var colorPathIndex = 0
    var stokePath = [UIBezierPath]() {
        didSet {
            for path in stokePath {
                path.lineWidth = 3
            }
            shouldDraw = true
            self.setNeedsDisplay()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = self.bounds
        backgroundLayer.strokeColor = UIColor.lightGrayColor()
        backgroundLayer.strokes = stokePath
        backgroundLayer.setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let lineColor = UIColor(red: 170.0 / 255.0,
                                green: 170.0 / 255.0,
                                blue: 170.0 / 255.0, alpha: 0.6)
        self.drawLineDash(inRect: rect,
                          lineColor: lineColor,
                          startPosition: CGPoint(x: rect.width / 2, y: 0),
                          endPosition: CGPoint(x: rect.width / 2, y: rect.height))
        self.drawLineDash(inRect: rect,
                          lineColor: lineColor,
                          startPosition: CGPoint(x: 0, y: rect.height / 2),
                          endPosition: CGPoint(x: rect.width, y: rect.height / 2))

        self.drawRoundPath(inRect: rect)
        if shouldDraw {
            layer.addSublayer(backgroundLayer)
        }
        //draw color line
        if colorPathIndex < stokePath.count {
            let path = stokePath[colorPathIndex]
            self.drawColorLine(path)
        }
    }

    func drawColorLine(bezierPath: UIBezierPath) {
        colorLayer.frame = self.bounds
        colorLayer.strokeColor = UIColor.blackColor()
        colorLayer.strokes = [bezierPath]
        colorLayer.setNeedsDisplay()
        layer.addSublayer(colorLayer)
    }

    func drawLineDash(inRect inRect: CGRect, lineColor: UIColor = UIColor.lightGrayColor(), startPosition: CGPoint, endPosition: CGPoint) {
        let path = UIBezierPath()
        path.moveToPoint(startPosition)
        path.addLineToPoint(endPosition)
        path.setLineDash([4, 4], count: 2, phase: 2)
        path.lineWidth = 2
        path.lineCapStyle = .Butt;
        path.lineJoinStyle = .Round;
        lineColor.setStroke()
        path.stroke()
        path.closePath()
    }

    func drawRoundPath(inRect inRect: CGRect) {
        let path = UIBezierPath(roundedRect: inRect, cornerRadius: 0)
        path.lineWidth = 5
        path.lineCapStyle = .Square;
        path.lineJoinStyle = .Round;
        UIColor.lightGrayColor().setStroke()
        path.stroke()
        path.closePath()
    }
}
