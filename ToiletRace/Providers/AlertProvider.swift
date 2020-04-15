//
//  AlertProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

protocol AlertProvider {}

extension AlertProvider where Self: UIViewController {
    
    func presentGeneralError(_ error: Error? = nil) {
        let message = error?.message ?? "Something went wrong..."
        let alert = UIAlertController(title: "Ops",
                                      message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionOk)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentAlert(_ title: String, subtitle: String, firstButtonTitle: String, secondButtonTitle: String?, firstCompletion: @escaping () -> (), secondCompletion: (() -> ())?) {
        let alert = UIAlertController(title: title,
                                      message: subtitle, preferredStyle: .alert)
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default) { (_) in
            firstCompletion()
        }
        alert.addAction(firstAction)
        if let secondButtonTitle = secondButtonTitle {
            let firstAction = UIAlertAction(title: secondButtonTitle, style: .default) { (_) in
                secondCompletion?()
            }
            alert.addAction(firstAction)
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentFieldAlert(_ title: String, subtitle: String, textPlaceholder: String, firstButtonTitle: String, secondButtonTitle: String?, firstCompletion: @escaping (String) -> (), secondCompletion: (() -> ())?) {
        let alert = UIAlertController(title: title,
                                      message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = textPlaceholder
        }
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default) { (_) in
            firstCompletion(alert.textFields?.first?.text ?? "Room\(testName())")
        }
        alert.addAction(firstAction)
        if let secondButtonTitle = secondButtonTitle {
            let firstAction = UIAlertAction(title: secondButtonTitle, style: .default) { (_) in
                secondCompletion?()
            }
            alert.addAction(firstAction)
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
