//
//  StrokeDrawingView
//  Education
//
//  Created by Nguyen Van Dung on 10/30/16.
//  Copyright © 2016 Dht. All rights reserved.
//


import UIKit
import RealmSwift

let textForeground = UIColor.whiteColor()
public protocol StrokeDrawingViewDataSource: class {
    func sizeOfDrawing() -> CGSize
    func numberOfStrokes() -> Int
    func pathForIndex(index: Int) -> UIBezierPath
    func animationDurationForStroke(index: Int) -> CFTimeInterval
    func colorForStrokeAtIndex(index: Int) -> UIColor
    func colorForUnderlineStrokes() -> UIColor?
    func textToDraw() -> [TextModel]
}

public protocol StrokeDrawingViewDataDelegate: class {
    func layersAreNowReadyForAnimation()
}

public class KanjiStrokeDrawingView: UIView {

    private let defaultMiterLimit: CGFloat = 4
    private var numberOfStrokes: Int { return dataSource?.numberOfStrokes() ?? 0 }
    private var shouldDraw = false
    private var shouldDrawStrokeText = false
    private var strokeLayers = [CAShapeLayer]()
    private var backgroundLayer = BackgroundLayer()
    private var drawingSize = CGSizeZero
    private var animations = [CABasicAnimation]()
    private var timer: NSTimer?
    private var widthScalce: CGFloat = 0
    private var heightScalce: CGFloat = 0
    private var drawRect = CGRect.zero
    private var currentIndex = 0

    var kanjiInfo: KanjiModel? {
        didSet {
            shouldDrawStrokeText = true
            let boundSize = dataSource?.sizeOfDrawing() ?? CGSize.zero
            let boxRect = CGRect(origin: CGPoint.zero, size: boundSize)
            self.drawRect = Utils.makeDrawingRect(boxRect, bound: self.bounds)
            var preferredRect = self.kanjiInfo?.viewBoxRect ?? CGRect.zero
            if preferredRect.isEmpty {
                preferredRect = drawRect
            }
            let nativeWidth = preferredRect.width
            self.widthScalce = drawRect.width / nativeWidth
            let nativeHeight = preferredRect.height
            self.heightScalce = drawRect.height / nativeHeight
            self.drawingSize = drawRect.size
            self.layoutSubviews()
            self.setNeedsDisplay()
        }
    }
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public API
    /// Custom drawing starts afte this property is set
    public var dataSource: StrokeDrawingViewDataSource? {
        didSet {
            guard let _ = dataSource else {return}
            shouldDraw = true
            setNeedsDisplay()
        }
    }

    public var delegate: StrokeDrawingViewDataDelegate?

    /// Use this method to run looped animation
    public func playForever(delayBeforeEach: CFTimeInterval = 0) {

        guard let dataSource = dataSource else {return}
        let numberOfStrokes = dataSource.numberOfStrokes()
        var animationDuration: CFTimeInterval = 0
        for i in 0..<numberOfStrokes {
            animationDuration += dataSource.animationDurationForStroke(i)
        }

        playSingleAnimation()
        timer = NSTimer.scheduledTimerWithTimeInterval(delayBeforeEach + animationDuration,
                                                       target: self,
                                                       selector: #selector(self.playSingleAnimation),
                                                       userInfo: nil,
                                                       repeats: true)
    }

    /// Use this method to stop looped animation
    public func stopForeverAnimation() {
        timer?.invalidate()
        pauseLayers()
    }

    public func clean() {
        removeAnimationFromEachLayer()
        resetLayers()
        for layer in strokeLayers {
            layer.removeFromSuperlayer()
        }
        strokeLayers = [CAShapeLayer]()
    }

    /// Use this method to run single animation cycle
    public func playSingleAnimation() {
        removeAnimationFromEachLayer()
        setStrokesProgress(0)
        resetLayers()

        var counter = 0
        var duration: CFTimeInterval = CACurrentMediaTime()

        for strokeLayer in strokeLayers {

            let delay = duration
            let strokeAnimationDuration = dataSource?.animationDurationForStroke(counter) ?? 0
            duration += strokeAnimationDuration

            let anim = defaultAnimation(strokeAnimationDuration, delayTime: delay)
            strokeLayer.addAnimation(anim, forKey: "strokeEndAnimation")

            counter += 1
        }
    }


    public func setStrokesProgress(progress: CGFloat) {
        for strokeLayer in strokeLayers {
            strokeLayer.strokeEnd = progress
        }
    }
}


// MARK:
extension KanjiStrokeDrawingView {

    private func pauseLayers() {
        for strokeLayer in strokeLayers {
            strokeLayer.pause()
        }
    }

    private func resetLayers() {
        for strokeLayer in strokeLayers {
            strokeLayer.reset()
        }
    }

    private func removeAnimationFromEachLayer() {
        for strokeLayer in strokeLayers {
            strokeLayer.removeAllAnimations()
        }
    }

    private func drawIfNeeded() {
    
        if shouldDraw == true && numberOfStrokes > 0 {
            layer.addSublayer(backgroundLayer)
            for strokeIndex in 0..<numberOfStrokes {
                let color = dataSource?.colorForStrokeAtIndex(strokeIndex) ?? UIColor.blackColor()
                let shapeLayer = CAShapeLayer()
                shapeLayer.fillColor = nil
                shapeLayer.strokeColor = color.CGColor
                shapeLayer.miterLimit = defaultMiterLimit
                shapeLayer.lineCap = kCALineCapRound
                shapeLayer.lineJoin = kCALineJoinRound

                shapeLayer.strokeEnd = 0.0
                layer.addSublayer(shapeLayer)
                strokeLayers.append(shapeLayer)
            }
            shouldDraw = false
            delegate?.layersAreNowReadyForAnimation()
        }
        if shouldDrawStrokeText {
            self.drawStrokeText()
        }
    }

    func drawStrokeText() {
        if let textModels = dataSource?.textToDraw() {
            for i in 0..<textModels.count {
                if i <= currentIndex {
                    let model = textModels[i]
                    let apoint = model.origin
                    let labelRect = CGRectMake(apoint.x * self.widthScalce + 5, apoint.y * self.heightScalce - 10, 9, 11)
                    let labelStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                    labelStyle.alignment = .Center

                    let labelFontAttributes = [NSFontAttributeName: UIFont(name: "Helvetica", size: 8)!, NSForegroundColorAttributeName: textForeground, NSParagraphStyleAttributeName: labelStyle]

                    model.value.drawInRect(labelRect, withAttributes: labelFontAttributes)
                }
            }
        }
    }

    private func defaultAnimation(duration: CFTimeInterval, delayTime: CFTimeInterval = 0, removeOnComletion: Bool = false) -> CABasicAnimation {
        let baseAnim = CABasicAnimation(keyPath: "strokeEnd")
        baseAnim.duration = duration
        baseAnim.beginTime = delayTime
        baseAnim.fromValue = 0
        baseAnim.fillMode = kCAFillModeForwards
        baseAnim.removedOnCompletion = removeOnComletion
        baseAnim.toValue = 1
        baseAnim.delegate = self
        return baseAnim
    }

    public override func drawRect(rect: CGRect) {
        drawIfNeeded()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let dataSource = dataSource where strokeLayers.count > 0 else {return}
        var pathes = [UIBezierPath]()
        for strokeIndex in 0..<numberOfStrokes {

            let strokeLayer = strokeLayers[strokeIndex]

            let path = dataSource.pathForIndex(strokeIndex)
            let pathCopy = UIBezierPath(CGPath: path.CGPath)
            pathCopy.lineWidth = path.lineWidth * self.widthScalce
            pathes.append(pathCopy)
            pathCopy.applyTransform(CGAffineTransformMakeScale(self.widthScalce, self.heightScalce))

            strokeLayer.lineWidth = path.lineWidth * self.widthScalce
            strokeLayer.path = pathCopy.CGPath
        }

        if let underlineColor = dataSource.colorForUnderlineStrokes() {
            backgroundLayer.frame = drawRect
            backgroundLayer.strokeColor = underlineColor
            backgroundLayer.strokes = pathes
            backgroundLayer.setNeedsDisplay()
        }
    }
}

extension KanjiStrokeDrawingView: CAAnimationDelegate {
    public func animationDidStart(anim: CAAnimation) {
        var i  = 0
        for stroke in self.strokeLayers {
            if let animation = stroke.animationForKey("strokeEndAnimation") {
                if anim == animation {
                    currentIndex = i
                    self.setNeedsDisplay()
                    break
                }
            }
            i += 1
        }
    }
}

extension CALayer {
    
    func pause() {
        let pausedTime = convertTime(CACurrentMediaTime(), fromLayer: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    
    func reset() {
        speed = 1.0
        timeOffset = 0.0
    }
    
    func resume() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        beginTime = timeSincePause
    }
}
