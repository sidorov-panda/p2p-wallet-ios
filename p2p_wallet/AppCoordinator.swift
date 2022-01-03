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
    
    // MARK: - Initializer
    init(window: UIWindow?) {
        self.window = window
        bind()
    }
    
    // MARK: - Methods
    private func bind() {
        appEventHandler.delegate = self
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
        navigateNext(withAuthenticationOnMain: true)
    }
    
    func navigateNext(withAuthenticationOnMain: Bool = false) {
        // set placeholder vc
        changeRootViewController(to: PlaceholderViewController())
        
        // try to retrieve account from seed
        // wait 300 ms for process of relacing rootViewController to complete
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
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
                    self?.showMainScene(withAuthentication: withAuthenticationOnMain)
                }
            }
        }
    }
    
    // MARK: - Navigation
    private func showCreateOrRestoreWalletScene() {
        let vc = CreateOrRestoreWallet.ViewController()
        let nc = UINavigationController(rootViewController: vc)
        changeRootViewController(to: nc)
    }
    
    private func showOnboardingScene() {
        let vc = Onboarding.ViewController()
        changeRootViewController(to: vc)
    }
    
    private func showMainScene(withAuthentication: Bool) {
        // MainViewController
        let vc = MainViewController()
        vc.authenticateWhenAppears = withAuthentication
        changeRootViewController(to: vc)
    }
    
    // MARK: - Helpers
    private func changeRootViewController(to vc: UIViewController) {
        // TODO: - Animation
        window?.rootViewController = vc
    }
}

extension AppCoordinator: AppEventHandlerDelegate {
    func createWalletDidComplete() {
        navigateNext()
    }
    
    func restoreWalletDidComplete() {
        navigateNext()
    }
    
    func onboardingDidFinish() {
        navigateNext()
    }
    
    func userDidChangeAPIEndpoint(to endpoint: SolanaSDK.APIEndPoint) {
        navigateNext()
    }
    
    func userDidChangeLanguage(to language: LocalizedLanguage) {
        navigateNext()
    }
    
    func userDidLogout() {
        navigateNext()
    }
}
