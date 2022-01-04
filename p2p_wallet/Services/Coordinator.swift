//
//  Coordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 04/01/2022.
//

import Foundation

// MARK: - General Coordinator
protocol CoordinatorType: AnyObject {
    // MARK: - Properties
    var didCancel: ((CoordinatorType) -> Void)? { get set }
    
    // MARK: - Methods
    func start()
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)
}

extension CoordinatorType {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {}
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {}
}

// MARK: - Coordinator with single child
protocol SingleChildCoordinatorType: AnyObject {
    // MARK: - Properties
    var child: CoordinatorType? {get set}
}

extension SingleChildCoordinatorType {
    func setChildCoordinator(_ coordinator: CoordinatorType) {
        // release coordinator when finished
        coordinator.didCancel = {[weak self] _ in
            self?.child = nil
        }
        
        // start coordinator
        coordinator.start()
        
        // keep reference to coordinator
        child = coordinator
    }
    
    func popChildCoordinator() {
        child = nil
    }
}
