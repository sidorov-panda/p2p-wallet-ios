//
//  AppCoordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/01/2022.
//

import Foundation
import UIKit
import RxSwift

final class AppCoordinator {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let window: UIWindow?
    private let storage: AccountStorageType & PincodeStorageType & NameStorageType = Resolver.resolve()
    private var appEventHandler: AppEventHandlerType = Resolver.resolve()
    private var showAuthenticationOnMainOnAppear = true
    
    // MARK: - Initializer
    init(window: UIWindow?) {
        self.window = window
        bind()
    }
    
    // MARK: - Methods
    private func bind() {
        appEventHandler.reloadHandler = {[weak self] in self?.reload()}
        appEventHandler.isLoadingDriver
            .drive(onNext: {[weak self] isLoading in
                if isLoading {
                    self?.window?.showLoadingIndicatorView()
                } else {
                    self?.window?.hideLoadingIndicatorView()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func start() {
        reload()
    }
    
    func reload() {
        // set placeholder vc
        changeRootViewController(to: PlaceholderViewController())
        
        // try to retrieve account from seed
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let account = self?.storage.account
            DispatchQueue.main.async { [weak self] in
                if account == nil {
                    self?.showCreateOrRestoreWalletScene()
                } else if self?.storage.pinCode == nil ||
                            !Defaults.didSetEnableBiometry ||
                            !Defaults.didSetEnableNotifications
                {
                    self?.showOnboardingScene()
                } else {
                    self?.showMainScene()
                }
            }
        }
    }
    
    // MARK: - Navigation
    private func showCreateOrRestoreWalletScene() {
        let vc = CreateOrRestoreWallet.ViewController()
        let nc = UINavigationController(rootViewController: vc)
        changeRootViewController(to: nc)
        showAuthenticationOnMainOnAppear = false
    }
    
    private func showOnboardingScene() {
        let vc = Onboarding.ViewController()
        changeRootViewController(to: vc)
    }
    
    private func showMainScene() {
        // MainViewController
        let vc = MainViewController()
        vc.authenticateWhenAppears = showAuthenticationOnMainOnAppear
        changeRootViewController(to: vc)
    }
    
    // MARK: - Helpers
    private func changeRootViewController(to vc: UIViewController) {
        // TODO: - Animation
        window?.rootViewController = vc
    }
}
