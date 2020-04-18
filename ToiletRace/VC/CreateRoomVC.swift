//
//  CreateRoomView.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 18/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

protocol CreateRoomDelegate {
    func shouldCreateRoom(name: String, isPrivate: Bool)
}

import UIKit

class CreateRoomVC: UIViewController {
    
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentView: UIView!

    var isPrivate = false
    var delegate: CreateRoomDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tap.cancelsTouchesInView = false
        blurView.addGestureRecognizer(tap)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.labelBlack.cgColor
        addKeyboardObserver()
        preAnimation()
    }
    
    deinit {
        removeKeyboardObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        expand()
    }
    
    func expand() {
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView.alpha = 1
            self.contentView.transform = CGAffineTransform.identity
        }) { (_) in
            self.textField.becomeFirstResponder()
        }
    }
    
    private func preAnimation() {
        blurView.alpha = 0
        contentView.transform = originalTransform()
    }
    
    func closeAnimation() {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.4, animations: {
            self.blurView.alpha = 0
            self.contentView.transform = self.originalTransform()
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func enableButton() {
        createButton.backgroundColor = UIColor.aqua
        createButton.isEnabled = true
    }
    
    private func disableButton() {
        createButton.backgroundColor = UIColor.lightGray
        createButton.isEnabled = false
    }
    
    private func close() {
        closeAnimation()
    }
    
    private func originalTransform() -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: view.frame.height)
        transform = transform.scaledBy(x: 0.2, y: 1)
        return transform
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        isPrivate = sender.isOn
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        close()
    }
    
    @IBAction func createTapped(_ sender: UIButton) {
        delegate?.shouldCreateRoom(name: textField.text ?? "", isPrivate: isPrivate)
    }
    
    @objc func viewTapped() {
        textField.resignFirstResponder()
    }
    
}

extension CreateRoomVC: UITextFieldDelegate {
    
    @objc func textChanged(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            enableButton()
        } else {
            disableButton()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension CreateRoomVC: KeyboardProvider {
    
    func keyboardWillShow(_ notification: Notification) {
        UIView.animate(withDuration: 0.4, animations: {
            self.contentView.transform = CGAffineTransform(translationX: 0, y: -64)
        }) { (_) in }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4, animations: {
            self.contentView.transform = CGAffineTransform.identity
        }) { (_) in }
    }
    
    
    
}
