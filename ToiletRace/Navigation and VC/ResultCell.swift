//
//  ResultCell.swift
//  TheRace
//
//  Created by Enrico Castelli on 03/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var separatorLine: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    var index : Int? {
        didSet {
            positionLabel.text = "\((index ?? -1) + 1)"
            if index == players.count - 1 {
                separatorLine.isHidden = true
            } else {
                separatorLine.isHidden = false
            }
        }
    }
    var result : Result? {
        didSet {
            if result?.penalty == true {
                timeLabel.text = "\(result?.time.string() ?? "") + 3"
            } else {
                timeLabel.text = result?.time.string()
            }
            titleLabel.text = result?.player.name.rawValue
            if result?.player.name.rawValue == Data.shared.selectedPlayer.name.rawValue {
                titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: 16)
            }
        }
    }

    
}
