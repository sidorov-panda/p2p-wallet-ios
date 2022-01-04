//
//  CreateOrRestoreWallet.Coordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 04/01/2022.
//

import Foundation
import UIKit

extension CreateOrRestoreWallet {
    final class Coordinator: NSObject, CoordinatorType, SingleChildCoordinatorType {
        // MARK: - Properties
        private let navigationController: UINavigationController
        var didCancel: ((CoordinatorType) -> Void)?
        var child: CoordinatorType?
        
        // MARK: - Initializer
        init(navigationController: UINavigationController) {
            self.navigationController = navigationController
            super.init()
            self.navigationController.delegate = self
        }
        
        // MARK: - Methods
        func start() {
            let vc = CreateOrRestoreWallet.ViewController()
            vc.delegate = self
            navigationController.pushViewController(vc, animated: false)
        }
        
        private func cancel() {
            // Reset Navigation Controller
            navigationController.popToRootViewController(animated: true)

            // Invoke Handler
            didCancel?(self)
        }
        
        // MARK: - Navigation
        private func navigate(to scene: NavigatableScene) {
            switch scene {
            case .createWallet:
                let vc = CreateWallet.ViewController()
                navigationController.pushViewController(vc, animated: true)
            case .restoreWallet:
                let vc = RestoreWallet.ViewController()
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }
}

extension CreateOrRestoreWallet.Coordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        child?.navigationController(navigationController, willShow: viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        child?.navigationController(navigationController, didShow: viewController, animated: animated)
    }
}

extension CreateOrRestoreWallet.Coordinator: CreateOrRestoreWalletViewControllerDelegate {
    func createWalletDidTap() {
        navigate(to: .createWallet)
    }
    
    func restoreWalletDidTap() {
        navigate(to: .restoreWallet)
    }
}
