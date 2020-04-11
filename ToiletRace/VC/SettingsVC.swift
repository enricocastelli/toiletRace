//
//  SettingsVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 19/12/2019.
//  Copyright © 2019 Enrico Castelli. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, StoreProvider {

    @IBOutlet weak var segmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmented.selectedSegmentIndex = retrieveLevel()
        // Do any additional setup after loading the view.
    }

    @IBAction func segmentedTapped(_ sender: UISegmentedControl) {
        saveLevel(sender.selectedSegmentIndex)
    }
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigation.pop()
        
    }
    
}
