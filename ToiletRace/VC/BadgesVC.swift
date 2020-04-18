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
    @IBOutlet weak var explanationView: UIView!
    @IBOutlet weak var explanationLabel: UILabel!
    
    var array = [Badge]()
    var animationEnabled = true
    var bigView: RoundView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        badgesCollectionView.register(UINib(nibName: BadgeCell.id, bundle: nil), forCellWithReuseIdentifier: BadgeCell.id)
        if let time = getRecord() {
            minuteCounterView.update(time.minutes()) {}
            secondsCounterView.update(time.seconds()) {}
            decimalCounterView.update(time.ms()) {}
        } else {
            lapLabel.text = "NO RECORD SET YET"
            secondsCounterView.isHidden = true
            decimalCounterView.isHidden = true
            minuteCounterView.isHidden = true
        }
        explanationView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard bigView == nil else { return }
        array = Badge.array
        badgesCollectionView.reloadData()
        addBigView()
    }
    
    private func addBigView() {
        bigView = RoundView(frame: CGRect(x: 0, y: 0, width: view.frame.width*2, height: view.frame.width*2))
        bigView!.backgroundColor = UIColor.aqua.withAlphaComponent(0.2)
        bigView!.center = CGPoint(x: view.center.x, y: view.frame.height)
        bigView!.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.insertSubview(bigView!, at: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.bigView!.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension BadgesVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeCell.id, for: indexPath) as! BadgeCell
        let badge = Badge.array[indexPath.row]
        cell.badge = getBadges().contains(badge) ? badge : nil
        if animationEnabled {
            let delay = 0.2*Double(indexPath.row)
            cell.animateShowing(delay)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/5, height: view.frame.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        explanationLabel.text = Badge.array[indexPath.row].explanation
        UIView.animate(withDuration:0.3) {
            self.explanationView.transform = CGAffineTransform.identity
        }
    }
}

class RoundView: UIView {
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.height/2
    }
}
