//
//  FirstVC.swift
//  TheRace
//
//  Created by Enrico Castelli on 07/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class FirstVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        start(UIButton())
        
    }
    

    @IBAction func start(_ sender: UIButton) {
//        let gameVC = GameViewController.instantiate(with: Circuit.ApolloPoo)
//        Navigation.main.viewControllers = [gameVC]
//        Navigation.startLoading()
        let show = ShowroomVC()
        Navigation.main.pushViewController(show, animated: true)
    }
    
    @IBAction func chartTapped(_ sender: UIButton) {
        let chart = ChartVC()
        Navigation.main.viewControllers = [chart]
    }
    
    @IBAction func selectTapped(_ sender: UIButton) {
        let show = ShowroomVC()
        Navigation.main.present(show, animated: true) {
        }
    }
    
}
