//
//  FirstVC.swift
//  TheRace
//
//  Created by Enrico Castelli on 07/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func start(_ sender: UIButton) {
        let show = ShowroomVC()
        Navigation.main.pushViewController(show, animated: true)
    }
    
    @IBAction func multiplayerTapped(_ sender: UIButton) {
        let show = MultiplayerVC()
        Navigation.main.pushViewController(show, animated: true)
    }
    
    @IBAction func makeYoursTapped(_ sender: UIButton) {
        let show = PooMakerVC()
        Navigation.main.pushViewController(show, animated: true)
    }
    
}
