//
//  GameResultVC.swift
//  TheRace
//
//  Created by Enrico Castelli on 03/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

class GameResultVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var finalResults: [Result]
    var totalScores : [String: Float] = [:]

    init(results: [Result]) {
        finalResults = results
        super.init(nibName: String(describing: GameResultVC.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: ResultCell.self), bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        titleLabel.text = "RACE RESULTS"
        finalResults = finalResults.sorted { (obj1, obj2) -> Bool in
            return obj1.time < obj2.time
        }
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        let first = WelcomeVC()
        Navigation.main.viewControllers = [first]
    }
}

extension GameResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultCell
        cell.index = indexPath.row
        cell.result = finalResults[indexPath.row]
        return cell
    }
}

extension GameResultVC: UITableViewDelegate {
    
}

