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
    

    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
