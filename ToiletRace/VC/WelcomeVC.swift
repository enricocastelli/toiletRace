//
//  FirstVC.swift
//  TheRace
//
//  Created by Enrico Castelli on 07/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController, TextPresenter {


    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var multiplayerButton: UIButton!
    @IBOutlet weak var toiletPaperView: ToiletPaperView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var toiletPaperConstraint: NSLayoutConstraint!
    @IBOutlet weak var launchView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        let first = addText("THE TOILET", delay: 0.5, duration: 1, position: CGPoint(x: 36, y: 0), lineWidth: 1.5, font: Font.with(.hairline, 40), color: UIColor.black.withAlphaComponent(0.8), inView: titleContainerView)
        let second = addText("RACE", delay: 1.5, duration: 0.5, position: CGPoint(x: 36, y: first.frame.maxY + first.path!.boundingBox.height + 4), lineWidth: 3, font: Font.with(.hairline, 48), color: UIColor.black.withAlphaComponent(0.8), inView: titleContainerView)
        toiletPaperConstraint.constant = second.frame.maxY + second.path!.boundingBox.height + 4 + 64
        view.layoutIfNeeded()
        toiletPaperView.animatePaper(1)
        preAnimation()
        animation()
        startButton.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        multiplayerButton.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
    }
    
    private func preAnimation() {
        startButton.transform = CGAffineTransform(translationX: 0, y: view.frame.width)
        multiplayerButton.transform = CGAffineTransform(translationX: 0, y: view.frame.width)
        settingsButton.transform = CGAffineTransform(translationX: 0, y: view.frame.width)
        UIView.animate(withDuration: 0.3, animations: {
            self.launchView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (_) in
//            self.launchView.isHidden = true
        }
    }
    
    private func animation() {
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.startButton.transform = CGAffineTransform.identity
            self.multiplayerButton.transform = CGAffineTransform.identity
            self.settingsButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    @IBAction func start() {
        navigation.push(ShowroomVC())
    }
    
     @IBAction func multiplayerTapped() {
        navigation.push(MultiplayerVC())
    }
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        navigation.present(SettingsVC(), animated: true, completion: nil)
    }
}
