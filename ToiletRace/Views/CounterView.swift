//
//  CounterView.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 16/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

class CounterView : UIView {
    
    private var stack = UIStackView()
    private var labels : [CounterLabel] = []
    private var previousNumberArray = [String]()
    private var futureNumberArray = [String]()
    private var number: Int
    private var animationCompletion: ()->()
    private var animationCounter = 0

    
    init(_ number: Int, _ animationCompletion: @escaping() ->()) {
        self.number = number
        self.animationCompletion = animationCompletion
        super.init(frame: .zero)
        initStackView()
        createLabels(string: createEmptyString())
        let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            self.updateLabels()
        }
    }
    
    func update(_ number: Int, _ animationCompletion: @escaping() ->()) {
        self.animationCompletion = animationCompletion
        self.number = number
        updateLabels()
    }
    
    ///initialize stackView containing labels
    private func initStackView() {
        addContentView(stack)
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
    }
    
    /// update all the labels with a specific number, isCurrency or percentage
    func updateLabels() {
        previousNumberArray = futureNumberArray
        let string = toCounterString()
        // populating the futureNumberArray
        let arrayChar = string.map { (Character) -> Character in
            return Character
        }
        futureNumberArray = []
        for car in arrayChar {
            futureNumberArray.append(String(car))
        }
        animate()
    }
    
    func toCounterString() -> String {
        var string = String(self.number)
        if string.count == 1 {
            string = "0\(string)"
        }
        return string
    }

    private func createEmptyString() -> String {
        var string = ""
        for _ in 1...2 {
            string.append("0")
        }
        return string
    }
    
    /// create labels for every number and populate the labels arrays
    private func createLabels(string : String) {
        let arrayChar = string.map { (Character) -> Character in
            return Character
        }
        let shouldPopulatePreviousArray = !previousNumberArray.isEmpty
        for car in arrayChar {
            // create a label and add it to the stack, until the labels count is the same as the string count
            if labels.count != arrayChar.count {
                let label = createSingleLabel(car: car)
                labels.append(label)
                stack.addArrangedSubview(label)
            }
            if shouldPopulatePreviousArray {
                previousNumberArray.append(String(car))
            } else  {
                futureNumberArray.append(String(car))
            }
        }
        layoutIfNeeded()
    }
    
    /// create and return a single counter label with a specific character as text
    private func createSingleLabel(car: Character) -> CounterLabel {
        let label = CounterLabel(String(car))
        label.delegate = self
        return label
    }
    
    /// start the animations, triggering every label's animation
    public func animate() {
        for label in labels {
            guard let index = labels.firstIndex(of: label) else { return }
            let string = futureNumberArray[index]
            label.animateNumber(string)
        }
    }
    
    private func addConstraint() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: stack,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: stack,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: stack,
                                attribute: .leadingMargin,
                                relatedBy: .greaterThanOrEqual,
                                toItem: self,
                                attribute: .leadingMargin,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: stack,
                                attribute: .trailingMargin,
                                relatedBy: .lessThanOrEqual,
                                toItem: self,
                                attribute: .trailingMargin,
                                multiplier: 1,
                                constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.number = 0
        self.animationCompletion = {()}
        super.init(coder: aDecoder)
        initStackView()
        createLabels(string: createEmptyString())
    }
    
}

extension CounterView: CounterLabelDelegate {
    
    func didFinishAnimation() {
        animationCounter += 1
        let counterStops = String(Int(number)).count
        if animationCounter == counterStops {
            animationCompletion()
            animationCounter = 0
        }
    }
}


protocol CounterLabelDelegate {
    func didFinishAnimation()
}

class CounterLabel: UILabel {
    
    private var count = -1
    private var animationDuration = 0.2
    private var previousNumber : Int = 0
    private var futureNumber : Int = 0
    var delegate: CounterLabelDelegate?
        
    init(_ text: String) {
        super.init(frame: .zero)
        self.text = text
        font = Font.with(.light, 32)
        textAlignment = .center
        textColor = UIColor.black
    }
    
    func animateNumber(_ string: String) {
        guard let future = Int(string), let previous = Int(text ?? "") else { return }
        self.futureNumber = future
        self.previousNumber = previous
        let _ = Timer.scheduledTimer(withTimeInterval: getRandom(), repeats: false) { (_) in
            let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerCallback(_ :)), userInfo: nil, repeats: true)
        }
    }
    
    
    /// the actual animation method repeated. When the correct number is reached, it invalidates the timer.
    @objc private func timerCallback(_ sender: Timer) {
        // checks for the count
        guard count != futureNumber else {
            sender.invalidate()
            return
        }
        if count == -1 { count = previousNumber }
        let countdown = (futureNumber - previousNumber) <= 0
        if countdown { count -= 1 } else { count += 1 }
        if count == 10 { count = 0 } else if count == -1 { count = 9 }
        let anim = CATransition()
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        anim.type = CATransitionType.push
        anim.subtype = CATransitionSubtype.fromTop
        anim.duration = animationDuration
        layer.add(anim, forKey: "change")
        if count != futureNumber {
            text = String(count)
        } else {
            // no more need for the timer now
            text = String(futureNumber)
            sender.invalidate()
            delegate?.didFinishAnimation()
        }
    }
    
    private func getRandom() -> Double {
        return Double(arc4random_uniform(30))/100
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
