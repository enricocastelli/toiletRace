//
//  RoomCell.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 11/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell {
    
    static let id = String(describing: RoomCell.self)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    var room: Room? {
        didSet {
            guard let room = room else { return }
            titleLabel.text = room.name
            subtitleLabel.text = "\(room.players.count) Poop's"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}
