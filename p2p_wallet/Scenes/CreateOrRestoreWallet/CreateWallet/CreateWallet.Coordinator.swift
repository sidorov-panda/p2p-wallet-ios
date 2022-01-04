//
//  CreateWallet.Coordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 04/01/2022.
//

import Foundation
import UIKit

extension CreateWallet {
    final class Coordinator: CoordinatorType {
        // MARK: - Dependencies
        private let analyticsManager: AnalyticsManagerType = Resolver.resolve()
        
        // MARK: - Properties
        private let navigationController: UINavigationController
        var didCancel: ((CoordinatorType) -> Void)?
        
        // MARK: - Initializer
        init(navigationController: UINavigationController) {
            self.navigationController = navigationController
        }
        
        // MARK: - Methods
        func start() {
            analyticsManager.log(event: .createWalletOpen)
            navigate(to: .explanation)
        }
        
        // MARK: - Navigation
        private func navigate(to scene: NavigatableScene) {
            switch scene {
            case .explanation:
                let vc = ExplanationVC()
                vc.delegate = self
                navigationController.pushViewController(vc, animated: true)
            case .createPhrases:
                let vc = CreateSecurityKeys.ViewController()
                navigationController.pushViewController(vc, animated: true)
            case .reserveName(let owner):
                let vc = ReserveName.ViewController(kind: .reserveCreateWalletPart, owner: owner, reserveNameHandler: viewModel)
                navigationController.pushViewController(vc, animated: true)
            case .verifyPhrase(let phrase):
                let vm = VerifySecurityKeys.ViewModel(keyPhrase: phrase)
                let vc = VerifySecurityKeys.ViewController(viewModel: vm)
                navigationController.pushViewController(vc, animated: true)
            case .dismiss:
                navigationController.popViewController(animated: true)
            case .back:
                if childNavigationController.viewControllers.count > 1 {
                    childNavigationController.popViewController(animated: true)
                } else {
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension CreateWallet.Coordinator: CreateWalletExplanationVCDelegate {
    func explanationDidFinish() {
        navigate(to: .createPhrases)
    }
    
    func explanationDidTapBack() {
        didCancel?(self)
    }
}
