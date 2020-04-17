//
//  BadgesVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 16/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit

class BadgesVC: UIViewController, StoreProvider {

    
    @IBOutlet weak var lapLabel: UILabel!
    @IBOutlet weak var recordContainerView: UIView!
    @IBOutlet weak var badgesLabel: UILabel!
    @IBOutlet weak var badgesCollectionView: UICollectionView!
    @IBOutlet weak var minuteCounterView: CounterView!
    @IBOutlet weak var secondsCounterView: CounterView!
    @IBOutlet weak var decimalCounterView: CounterView!


    override func viewDidLoad() {
        super.viewDidLoad()
        badgesCollectionView.register(BadgeCell.self, forCellWithReuseIdentifier: "cell")
        if let time = getRecord() {
            minuteCounterView.update(time.minutes()) {}
            secondsCounterView.update(time.seconds()) {}
            decimalCounterView.update(time.ms()) {}
        } else {
            lapLabel.text = "NO RECORD SET YET"
            secondsCounterView.isHidden = true
            decimalCounterView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBigView()
    }
    
    private func addBigView() {
        let bigView = RoundView(frame: CGRect(x: 0, y: -view.frame.height/2, width: view.frame.width*2, height: view.frame.width*2))
        bigView.backgroundColor = UIColor.aqua.withAlphaComponent(0.4)
        bigView.center = CGPoint(x: view.center.x, y: 0)
        bigView.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.insertSubview(bigView, at: 0)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [], animations: {
            bigView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension BadgesVC: UICollectionViewDataSource, UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Badge.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BadgeCell
        let badge = Badge.array[indexPath.row]
        cell.label.text = badge.desc
        if getBadges().contains(badge) {
            cell.label.font = Font.with(.bold, 18)
        }
        return cell
    }
}


class BadgeCell: UICollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addContentView(label)
        label.font = Font.with(.light, 16)
        label.textAlignment = .center
        label.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RoundView: UIView {
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.height/2
    }
}
