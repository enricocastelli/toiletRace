//
//  PaperTitleView.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 11/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class ToiletPaperView: UIView {
    
    private var paperImageView = UIImageView(image: UIImage.paper)
    private var whiteView = UIView()
    private var widthConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setWhiteView()
        setImages()
    }
    
    private func setWhiteView() {
        addSubview(whiteView)
        whiteView.alpha = 0
        whiteView.backgroundColor = UIColor(hex: "E8E8EA")
        whiteView.layer.borderColor = UIColor(hex: "374D62").cgColor
        whiteView.layer.borderWidth = 2.5
        whiteView.setConstraint(constraint: .leading, constant: 16)
        whiteView.setConstraint(constraint: .top, constant: 4)
        whiteView.setConstraint(constraint: .bottom, constant: -8)
        widthConstraint = NSLayoutConstraint(item: whiteView,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .width,
                                             multiplier: 1,
                                             constant: 1)
        widthConstraint.isActive = true
    }
    
    private func setImages() {
        paperImageView.contentMode = .scaleAspectFit
        addSubview(paperImageView)
        paperImageView.setConstraint(constraint: .leading, constant: 0)
        paperImageView.setConstraint(constraint: .top, constant: 0)
        paperImageView.setConstraint(constraint: .bottom, constant: 0)
        paperImageView.setAspectRatio(1, 1)
        paperImageView.alpha = 0
    }

    func animatePaper(_ delay: Double) {
        UIView.animate(withDuration: 0.3, delay: delay, options: [], animations: {
            self.paperImageView.alpha = 1
        }) { (_) in
            self.fadeWhiteView()
            self.animateRoll()
        }
    }
    
    private func fadeWhiteView() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            self.whiteView.alpha = 1
        }, completion: nil)
    }
    
    private func animateRoll() {
        UIView.animate(withDuration: 0.3, animations: {
            self.paperImageView.transform = CGAffineTransform(translationX: -4, y: 0)
        }) { (_) in
            self.widthConstraint.constant = self.frame.width - (self.paperImageView.frame.width/1.5)
            UIView.animate(withDuration: 1, delay: 0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
                self.paperImageView.transform = CGAffineTransform(translationX: self.frame.width - self.paperImageView.frame.width, y: 0)
                self.layoutIfNeeded()
                self.whiteView.addShadow()
            }) { (_) in
                UIView.animate(withDuration: 0.2) {
                    self.whiteView.layer.shadowOpacity = 0.1
                }
            }
        }
    }
        
    private func animateFurther() {

    }
}
