//
//  MakerCell.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 20/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class MakerCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    var item: String? {
        didSet {
            if let fruitImage = UIImage(named: item ?? "") {
                image.image = fruitImage
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

}
