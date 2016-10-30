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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var exportBtn: UIButton!
    @IBOutlet weak var drawView: KanjiStrokeDrawingView!
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
        drawView?.kanjiInfo = info
        drawView?.playForever(2)
        wordLabel?.sizeToFit()
        setupContentForScrollView()
    }

    func setupContentForScrollView() {
        let boxRect = info?.viewBoxRect ?? CGRect.zero
        let contentWith = CGFloat(bezierPaths.count) * boxRect.width
        let contentSize = CGSize(width: contentWith, height: scrollView.bounds.height)
        scrollView?.contentSize = contentSize
        var lineRect = CGRect.zero
        lineRect.size = boxRect.size
        for i in 0..<bezierPaths.count {
            let lineview = SingleStrokeView(frame: lineRect)
            lineview.backgroundColor = UIColor.whiteColor()
            lineview.stokePath = bezierPaths
            lineview.colorPathIndex = i
            scrollView?.addSubview(lineview)
            lineRect.origin.x += lineRect.width
        }
    }

    @IBAction func exportPdfAction(sender: AnyObject) {
        if let pdfImage = self.scrollView.screenShot() {
            let pdfData = PDFImageConverter.convertImageToPDF(pdfImage)
            let path = Utils.documentPath() + "/" + "kanji.pdf"
            do {
                try pdfData.writeToFile(path, options: NSDataWritingOptions.AtomicWrite)
            } catch {
                
            }
        }
    }
}

extension DrawViewController: StrokeDrawingViewDataSource {
    func sizeOfDrawing() -> CGSize {
        if let size = info?.viewBoxRect.size {
            return size
        }
        return CGSize(width: 109, height: 109)
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
