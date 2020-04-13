//
//  RankCell.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 12/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class RankCell: UITableViewCell {
    
    static let id = String(describing: RankCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconContainerView: RoundedView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressWidth: NSLayoutConstraint!
    
    var index = -1
    var result: Result? {
        didSet {
            // gameOver
            guard let result = result else { return }
            setForPoo(result.poo)
            if index != 0 {
                // poo is not first. Detail text show's time to Winner in red
                subtitleLabel.text = "\((result.timeToWinner ?? 0).stringAbs())"
                subtitleLabel.textColor = UIColor.red
            } else {
                // poo is first. Detail text show's time (or multiplayer not arrived yet)
                subtitleLabel.text = result.time == nil ? "NA" : "\(result.time!.string())"
                subtitleLabel.textColor = UIColor.black
            }
        }
    }
    var poo: Poo? {
        didSet {
            guard let poo = poo else { return }
            setForPoo(poo)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        progressWidth.constant = frame.width/2.5
        layoutIfNeeded()
        iconContainerView.isHidden = true
    }
    
    private func setForPoo(_ poo: Poo) {
        titleLabel.text = "\(index + 1) " + (poo.displayName ?? poo.name.rawValue)
        if let bonus = poo.bonus() {
            setBonus(bonus)
        }
        setLabels()
        progressView.progress = abs(poo.distance)/400
    }
    
    private func setBonus(_ bonus: Bonus) {
        iconView.image = bonus.image()
        if poo!.bonusEnabled && bonus != .NoBonus {
            iconContainerView.isHidden = false
        } else {
            iconContainerView.isHidden = true
        }
    }
    
    private func setLabels() {
        if poo == SessionData.shared.selectedPlayer {
            titleLabel.font = Font.with(.bold, 14)
            contentView.alpha = 1
        } else {
            titleLabel.font = Font.with(.medium, 13)
            contentView.alpha = 0.4
        }
    }
}
