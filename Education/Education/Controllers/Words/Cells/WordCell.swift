//
//  WordCell.swift
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation

class WordCell: UITableViewCell {

    @IBOutlet weak var wordLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        wordLabel?.font = UIFont(name: "KanjiStrokeOrders", size: 20)
    }
}
