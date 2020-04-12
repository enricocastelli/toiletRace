//
//  Navigation.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 17/12/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit


import UIKit

protocol DetailPresentable where Self: UIViewController {
    func animateOpening()
    func animateClosing()
}


class Navigation: UINavigationController, AlertProvider {
    
    fileprivate var detailOpeningFrame: CGRect?
    var isPresentingDetail: Bool {
        return lastVC is DetailPresentable
    }
    var loading: Loading?
    var swipe: UIPanGestureRecognizer!
    var lastVC: UIViewController? {
        return self.viewControllers.last
    }
    var firstVC: UIViewController? {
        return self.viewControllers.first
    }
    var isSwipeBackEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.isEnabled = false
        swipe = UIPanGestureRecognizer(target: self, action: #selector(swiped(_:)))
        swipe.delegate = self
        view.addGestureRecognizer(swipe)
    }
    
    func startLoading() {
        guard loading == nil else { return }
        loading = Loading()
        loading!.modalPresentationStyle = .overCurrentContext
        self.present(loading!, animated: false) {
        }
        loading!.startAnimating()
    }
    
    func stopLoading() {
        if let _ = loading {
            loading!.stopAnimating()
            loading = nil
        }
    }
    
    @objc func swiped(_ swipe: UIPanGestureRecognizer) {
        let loc = swipe.location(in: view)
        guard viewControllers.count > 1, let direction = swipe.direction, isSwipeBackEnabled else { return }
        switch swipe.state {
        case .ended:
            isPresentingDetail ? closeDetail() : pop()
        case .began:
            swipeBegan(loc, direction)
        default: break
        }
    }
    
    private func swipeBegan(_ loc: CGPoint, _ direction: GestureDirection) {
        if isPresentingDetail {
            guard direction == .Down  else {
                swipe.isEnabled = false
                defer { swipe.isEnabled = true }
                return
            }
        } else {
            guard loc.x < view.frame.width/2, direction == .Right else {
                swipe.isEnabled = false
                defer { swipe.isEnabled = true }
                return
            }
        }
    }
    
    func push(_ toVC: UIViewController, shouldRemove: Bool = false) {
        guard let window = UIApplication.shared.windows.first,
            let fromVC = lastVC else { return }
        let preanimationPosition: CGFloat = 8.0
        let previousPagePosition = -view.frame.width
        let nextPagePosition = view.frame.width
        toVC.view.frame = UIScreen.main.bounds
        toVC.view.transform = CGAffineTransform(translationX: nextPagePosition, y: 0)
        window.addSubview(toVC.view)
        UIView.animate(withDuration: 0.07, animations: {
            fromVC.view.transform = CGAffineTransform(translationX: preanimationPosition, y: 0)
        }, completion: { (_) in
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.allowUserInteraction], animations: {
                fromVC.view.transform = CGAffineTransform(translationX: previousPagePosition, y: 0)
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (_) in
                self.viewControllers.append(toVC)
                if shouldRemove {
                    self.viewControllers = [toVC]
                }
            })
        })
    }
    
    func goTo(_ toVC: UIViewController) {
        guard let window = UIApplication.shared.windows.first else { return }
        toVC.view.frame = UIScreen.main.bounds
        window.addSubview(toVC.view)
        self.viewControllers = [toVC]
    }
    
    func pop() {
        guard let window = UIApplication.shared.delegate?.window,
            self.viewControllers.count > 1,
            let fromVC = lastVC,
            let index = self.viewControllers.firstIndex(of: fromVC) else { return }
        let toVC = self.viewControllers[index - 1]
        let preanimationPosition: CGFloat = -8.0
        let previousPagePosition = view.frame.width
        let nextPagePosition = -view.frame.width
        toVC.view.transform = CGAffineTransform(translationX: nextPagePosition, y: 0)
        window?.addSubview(toVC.view)
        UIView.animate(withDuration: 0.07, animations: {
            fromVC.view.transform = CGAffineTransform(translationX: preanimationPosition, y: 0)
        }, completion: { (_) in
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.allowUserInteraction], animations: {
                fromVC.view.transform = CGAffineTransform(translationX: previousPagePosition, y: 0)
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (_) in
                self.viewControllers.removeLast()
            })
        })
    }
    
    func presentDetail(_ toVC: DetailPresentable, frame: CGRect) {
        guard let window = UIApplication.shared.delegate?.window,
        let fromVC = lastVC else { return }
        detailOpeningFrame = frame
        toVC.view.frame = frame
        toVC.modalPresentationStyle = .overCurrentContext
        window?.addSubview(toVC.view)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.allowUserInteraction], animations: {
            toVC.view.frame = fromVC.view.frame
            toVC.animateOpening()
        }, completion: { (_) in
            self.viewControllers.append(toVC)
        })
    }
    
    func closeDetail() {
        guard let window = UIApplication.shared.delegate?.window,
            let detailOpeningFrame = detailOpeningFrame,
            self.viewControllers.count > 1,
            let fromVC = lastVC,
            let detail = fromVC as? DetailPresentable,
            let index = self.viewControllers.firstIndex(of: fromVC) else { return }
        let toVC = self.viewControllers[index - 1]
        window?.insertSubview(toVC.view, at: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: [.allowUserInteraction], animations: {
            detail.view.frame = detailOpeningFrame
            detail.animateClosing()
        }, completion: { (_) in
            self.viewControllers.removeLast()
        })
    }
}

extension Navigation: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return isSwipeBackEnabled
    }
}

