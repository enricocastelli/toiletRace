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
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = getName()
        segmented.selectedSegmentIndex = retrieveLevel()
    }

    @IBAction func segmentedTapped(_ sender: UISegmentedControl) {
        saveLevel(sender.selectedSegmentIndex)
    }

    
    @IBAction func backTapped(_ sender: UIButton) {
        if let text = nameField.text, !text.isEmpty {
            setName(text)
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension SettingsVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
