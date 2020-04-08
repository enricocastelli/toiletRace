//
//  SettingsVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2019.
//  Copyright © 2019 Enrico Castelli. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var segmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmented.selectedSegmentIndex = StorageManager.retrieveLevel()
        // Do any additional setup after loading the view.
    }

    @IBAction func segmentedTapped(_ sender: UISegmentedControl) {
        StorageManager.saveLevel(sender.selectedSegmentIndex)
    }
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        Navigation.main.popViewController(animated: true)
        
    }
    
}
