                                                                                                                                                                                                                                                                                                                                                                                //
//  DrawViewController.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import RealmSwift


class DrawViewController: UIViewController {

    @IBOutlet weak var drawView: StrokeDrawingView!
    @IBOutlet weak var wordLabel: UILabel!
    var word: String = ""
    var info: KanjiModel? {
        didSet {
            if let models = info?.texts {
                for model in models {
                    model.calculateorigin(CGPoint.zero)
                    textModels.append(model)
                }
            }
        }
    }
    var bezierPaths = [UIBezierPath]()
    var textModels = [TextModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        wordLabel?.text = word
        drawView?.dataSource = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        drawView?.playForever(2)
        wordLabel?.sizeToFit()
    }
}

extension DrawViewController: StrokeDrawingViewDataSource {
    func sizeOfDrawing() -> CGSize {
        return                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              CGSize(width: 1000, height: 1000)
    }

    func numberOfStrokes() -> Int {
        return bezierPaths.count
    }

    func pathForIndex(index: Int) -> UIBezierPath {
        if index < bezierPaths.count {
            let bzPath = bezierPaths[index]
            return bzPath
        }
        return UIBezierPath()
    }

    func animationDurationForStroke(index: Int) -> CFTimeInterval {
        return 0.5
    }

    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    func colorForStrokeAtIndex(index: Int) -> UIColor {
        return generateRandomColor()
    }

    func colorForUnderlineStrokes() -> UIColor? {
        return UIColor.lightGrayColor()
    }

    func textToDraw() -> [TextModel] {
        return textModels
    }
}
