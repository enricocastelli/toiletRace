//
//  KeyboardProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 18/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

@objc protocol KeyboardProvider {
    
    func keyboardWillShow(_ notification:Notification)
    func keyboardWillHide(_ notification:Notification)

}

extension KeyboardProvider where Self: UIViewController {
    
    var isKeyboardVisible: Bool {
        get {
            return false
        }
        set(newValue) {}
    }
        
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            guard !(self?.isKeyboardVisible ?? false) else { return }
            self?.keyboardWillShow(notification)
            self?.isKeyboardVisible = true
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillHide(notification)
            self?.isKeyboardVisible = false
        }
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
