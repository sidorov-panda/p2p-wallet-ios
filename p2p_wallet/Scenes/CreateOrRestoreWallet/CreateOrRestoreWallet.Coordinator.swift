//
//  CreateOrRestoreWallet.Coordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 04/01/2022.
//

import Foundation
import UIKit

extension CreateOrRestoreWallet {
    final class Coordinator: CoordinatorType {
        // MARK: - Properties
        private let navigationController: UINavigationController
        var didFinish: ((CoordinatorType) -> Void)?
        
        // MARK: - Initializer
        init(navigationController: UINavigationController) {
            self.navigationController = navigationController
        }
        
        // MARK: - Methods
        func start() {
            let vc = CreateOrRestoreWallet.ViewController()
            vc.delegate = self
            navigationController.pushViewController(vc, animated: false)
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

extension CreateOrRestoreWallet.Coordinator: CreateOrRestoreWalletViewControllerDelegate {
    func createWalletDidTap() {
        navigate(to: .createWallet)
    }
    
    func restoreWalletDidTap() {
        navigate(to: .restoreWallet)
    }
}
