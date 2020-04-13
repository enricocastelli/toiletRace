//
//  GameResultVC.swift
//  TheRace
//
//  Created by Enrico Castelli on 03/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class GameResultVC: UIViewController {

    @IBOutlet weak var barView: BarView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barHeight: NSLayoutConstraint!
    @IBOutlet weak var barRatio: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!


    
    var finalResults: [Result]
    var animationEnabled = true

    init(results: [Result]) {
        finalResults = results
        super.init(nibName: String(describing: GameResultVC.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        titleLabel.text = "RACE RESULTS"
        finalResults = finalResults.sorted { (obj1, obj2) -> Bool in
            guard let time1 = obj1.time , let time2 = obj2.time else { return false }
            return time1 < time2
        }
        setBarView()
    }
    
    private func setTableView() {
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName: String(describing: ResultCell.self), bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 80, right: 0)
    }
    
    private func setBarView() {
        barView.onLeftTap = nil
        barView.rightImage = UIImage(systemName: "camera.fill")
        barView.onRightTap = share
        barView.lineHidden = false
    }
    
    private func share() {
        guard let img = takeScreenshot() else { return }
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        navigation.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func homeTapped(_ sender: UIButton) {
        navigation.push(WelcomeVC(), shouldRemove: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameResultVC: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultCell
        cell.index = indexPath.row
        cell.result = finalResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 2 {
            return 104
        } else {
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        bounceCell(indexPath.row, cell as! ResultCell)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animationEnabled = false
    }
    
    private func bounceCell(_ row: Int, _ cell: ResultCell){
        guard animationEnabled else { return }
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: view.frame.height)
        transform = transform.scaledBy(x: 0.4, y: 1)
        cell.transform = transform
        let duration = row <= 2 ? 0.4 : 0.3
        let delay = row <= 2 ? (0.3*Double(row)) : 1.0
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: [.curveEaseInOut], animations: {
            cell.transform = CGAffineTransform.identity
        }) { (_) in }
    }
}

    
extension GameResultVC: ScreenshotProvider {
   
    func willTakeScreenshot() {
        tableView.setContentOffset(.zero, animated: false)
        homeButton.isHidden = true
        barRatio.priority = .low
        barHeight.priority = .high
        topConstraint.constant = 40
        view.layoutIfNeeded()
    }
    
    func didTakeScreenShot() {
        homeButton.isHidden = false
        barHeight.priority = .low
        barRatio.priority = .high
        topConstraint.constant = 16
        view.layoutIfNeeded()
    }
    
}

