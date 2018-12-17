//
//  Navigation.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 23/10/2018.
//  Copyright © 2018 Enrico Castelli. All rights reserved.
//

import Foundation
import UIKit

class Navigation {
    
    static var main: UINavigationController!
    static var loading: Loading?
    
    static func startLoading() {
        let loading = Loading()
        loading.modalPresentationStyle = .overCurrentContext
        Navigation.main.present(loading, animated: false) {
        }
        self.loading = loading
        loading.startAnimating()
    }
    
    static func stopLoading() {
        if let loading = Navigation.loading {
            loading.stopAnimating()
            Navigation.loading = nil
        }
    }
}
