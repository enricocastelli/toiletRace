//
//  BadgeCell.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class BadgeCell: UICollectionViewCell {
    
    static let id = String(describing: BadgeCell.self)
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var badge: Badge? {
        didSet {
            guard let badge = badge else { return }
            label.text = badge.desc
            image.image = badge.image
            image.alpha = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func animateShowing(_ delay: Double) {
        contentView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: [], animations: {
            self.contentView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
