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
    }
    

    @IBAction func start(_ sender: UIButton) {
        let show = ShowroomVC()
        Navigation.main.pushViewController(show, animated: true)
    }
    
}
