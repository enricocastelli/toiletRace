//
//  ResultCell.swift
//  TheRace
//
//  Created by Enrico Castelli on 03/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var timeToLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var midConstraint: NSLayoutConstraint!
    
    var index = -1 {
        didSet {
            timeToLabel.isHidden = index == 0
            if index <= 2 {
                firstPositionsSet()
            } else {
                lastPositionsSet()
            }
            switch (index + 1) {
            case 1: positionLabel.text = "🏆"
            case 2: positionLabel.text = "🥈"
            case 3: positionLabel.text = "🥉"
            default: positionLabel.text = "\((index) + 1)"
            }
        }
    }
    var result : Result? {
        didSet {
            guard let result = result else { return }
            timeLabel.text = (result.time ?? 0).string()
            nameLabel.text = result.poo.displayName ?? result.poo.name.rawValue
            timeToLabel.text = (result.timeToWinner ?? 0).stringAbs()
            iconView.image = UIImage.pooImage(result.poo.name)
            if result.poo == SessionData.shared.selectedPlayer {
                contentView.layer.borderColor = UIColor.labelBlack.cgColor
                contentView.layer.borderWidth = 1.4
                nameLabel.font = index <= 2 ? Font.with(.bold, 23) : Font.with(.bold, 16)
                bounce()
            } else {
                contentView.layer.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.layer.cornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
    }
    
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientForIndex()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = bounds
        contentView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func gradientForIndex() -> [CGColor] {
        switch index + 1 {
            case 1: return UIColor.goldGradient
            case 2: return UIColor.silverGradient
            case 3: return UIColor.bronzeGradient
        default: return [UIColor.clear.cgColor]
        }
    }
    
    private func firstPositionsSet() {
        setGradientBackground()
        nameLabel.font = Font.with(.light, 23)
        timeLabel.font = Font.with(.light, 16)
        timeToLabel.font = Font.with(.light, 14)
        topConstraint.constant = 10
        bottomConstraint.constant = 10
        midConstraint.constant = 10
        dropShadow()
    }
    
    private func lastPositionsSet() {
        nameLabel.font = Font.with(.light, 16)
        timeLabel.font = Font.with(.light, 13)
        timeToLabel.font = Font.with(.light, 10)
        topConstraint.constant = 2
        bottomConstraint.constant = 2
        midConstraint.constant = 0
        backgroundColor = .white
    }
    
    private func dropShadow() {
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.black.cgColor
    }
    
    private func bounce() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.contentView.transform = CGAffineTransform.identity
            self.contentView.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
        }, completion: nil)
    }
}
