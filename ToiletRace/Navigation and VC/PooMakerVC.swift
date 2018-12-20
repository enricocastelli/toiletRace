//
//  PooMakerVC.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 20/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import UIKit


class PooMakerVC: UIViewController {

    @IBOutlet weak var pooImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 200)
    fileprivate let itemsPerRow: CGFloat = 4

    var items = PooMaker.items
    var addedItems : [FoodItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addedItems = []
    }
    
    func setupCollectionView() {
        collectionView.dragInteractionEnabled = true
        collectionView.register(UINib(nibName: String(describing: MakerCell.self), bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.reorderingCadence = .immediate
    }

    func animateImage() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .beginFromCurrentState], animations: {
            self.pooImage.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }) { (done) in
            self.pooImage.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        Navigation.main.popViewController(animated: true)
    }
    
    @IBAction func goTapped(_ sender: UIButton) {
        guard addedItems.count > 0 else { return }
        let result = PooMakerShowroomVC(items: addedItems)
        Navigation.main.pushViewController(result, animated: true)
    }
}

extension PooMakerVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MakerCell
        cell.item = items[indexPath.row].name
        return cell
    }
}

extension PooMakerVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = 64
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension PooMakerVC: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.items[indexPath.row]
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
}

extension PooMakerVC: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        switch coordinator.proposal.operation
        {
        case .move:
            let location = coordinator.session.location(in: self.view)
            if pooImage.frame.contains(location) {
                guard let index = coordinator.items.first?.sourceIndexPath?.row, items.count > index else { return }
                animateImage()
                addedItems.append(items[index])
            }
            break
        case .copy:
            break
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if session.localDragSession != nil
        {
            if collectionView.hasActiveDrag
            {
                
                return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
            }
            else
            {
                return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
            }
        }
        else
        {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
}

