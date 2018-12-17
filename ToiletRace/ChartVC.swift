//
//  ChartVC.swift
//  TheRace
//
//  Created by Enrico Castelli on 07/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit

struct TotalResult {
    var name: String
    var points: Int
}

class ChartVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var totalPoints : [TotalResult] = []
    var players : [Poo] = [Poo(name: .GuanoStar), Poo(name: .HoleRunner), Poo(name: .IndianSurprise),Poo(name: .BrownTornado), Poo(name: .ApolloPoo)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: ChartCell.self), bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = 40
        getData()
    }
    
    func getData() {
        for play in players {
            let total = Storage.getScore(name: play.name.rawValue)
            totalPoints.append(TotalResult(name: play.name.rawValue, points: total ?? 0))
        }
        totalPoints = totalPoints.sorted { (obj1, obj2) -> Bool in
            return obj1.points > obj2.points
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        let firstVC = FirstVC()
        self.navigationController?.viewControllers = [firstVC]
    }
    @IBAction func reset(_ sender: UIButton) {
        for play in players {
            Storage.reset(name: play.name.rawValue)
            totalPoints = []
        }
        tableView.reloadData()
    }
}

extension ChartVC: UITableViewDelegate {
    
    
    
}

extension ChartVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChartCell
        cell.index = indexPath.row
        cell.titleLabel.text = totalPoints[indexPath.row].name
        cell.pointsLabel.text = "\(totalPoints[indexPath.row].points)"
        return cell
    }
    


}
