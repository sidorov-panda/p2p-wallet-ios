//
//  AppCoordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/01/2022.
//

import Foundation
import UIKit

class AppCoordinator {
    // MARK: - Properties
    private let window: UIWindow?
    
    // MARK: - Initializer
    init(window: UIWindow?) {
        self.window = window
    }
    
    // MARK: - Methods
    func start() {
        reload()
    }
    
    func reload() {
        // set placeholder vc
        window?.rootViewController = PlaceholderViewController()
        
        
    }
}
