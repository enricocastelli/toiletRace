//
//  BarView.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 11/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class BarView: UIView {
    
    var onLeftTap:  (() -> ())?
    var onRightTap: (() -> ())?
    var leftImage: UIImage? {
        didSet {
            leftButton.setImage(leftImage, for: .normal)
        }
    }
    var rightImage: UIImage? {
        didSet {
            rightButton.setImage(rightImage, for: .normal)
        }
    }
    var lineHidden = false {
        didSet {
            line.isHidden = lineHidden
        }
    }

    var leftButton = UIButton()
    var rightButton = UIButton()
    private var line = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLeftButton()
        setRightButton()
        setLine()
        clipsToBounds = true
    }
    
    private func setLeftButton() {
        leftButton.setImage(UIImage(systemName: "arrow.left.circle.fill"), for: .normal)
        leftButton.tintColor = UIColor.lightGray
        addSubview(leftButton)
        leftButton.contentMode = .scaleAspectFit
        leftButton.setConstraint(constraint: .leading, constant: 16)
        leftButton.setConstraint(constraint: .centerY, constant: 16)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        leftButton.setAspectRatio(1, 1)
        leftButton.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
    }
    
    private func setRightButton() {
        rightButton.setImage(UIImage(systemName: "arrow.right.circle.fill"), for: .normal)
        rightButton.tintColor = UIColor.lightGray
        addSubview(rightButton)
        rightButton.contentMode = .scaleAspectFit
        rightButton.setConstraint(constraint: .trailing, constant: -16)
        rightButton.setConstraint(constraint: .centerY, constant: 16)
        rightButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        rightButton.setAspectRatio(1, 1)
        rightButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
    }

    private func setLine() {
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        addSubview(line)
        line.setSelfConstraint(constraint: .height, constant: 1)
        line.setConstraint(constraint: .trailing, constant: -40)
        line.setConstraint(constraint: .leading, constant: 40)
        line.setConstraint(constraint: .bottom, constant: 0)
    }
    
    func animateRightButton() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            self.rightButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: nil)
    }

    func stopAnimateRightButton() {
        rightButton.layer.removeAllAnimations()
    }
    
    @objc private func leftTapped() {
        onLeftTap?()
    }
    
    @objc private func rightTapped() {
        onRightTap?()
    }
}
