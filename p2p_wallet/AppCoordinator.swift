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
    // MARK: - Dependencies
    private let storage: AccountStorageType & PincodeStorageType & NameStorageType = Resolver.resolve()
    private var appEventHandler: AppEventHandlerType = Resolver.resolve()
    private let analyticsManager: AnalyticsManager = Resolver.resolve()
    
    // MARK: - Properties
    private var childCoordinator: CoordinatorType?
    private let disposeBag = DisposeBag()
    private let window: UIWindow?
    private var isRestoration: Bool = false
    
    // MARK: - Initializer
    init(window: UIWindow?) {
        self.window = window
        window?.rootViewController = PlaceholderViewController()
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
    
    func start(authenticateOnMain: Bool = true) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let account = self?.storage.account
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                if account == nil {
                    self.showCreateOrRestoreWalletScene(completion: nil)
                } else if self.storage.pinCode == nil ||
                            !Defaults.didSetEnableBiometry ||
                            !Defaults.didSetEnableNotifications
                {
                    self.showOnboardingScene(completion: nil)
                } else {
                    self.showMainScene(withAuthentication: authenticateOnMain, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Navigation
    private func showCreateOrRestoreWalletScene(completion: (() -> Void)?) {
        let nc = UINavigationController()
        changeRootViewController(to: nc) { [weak nc, weak self] in
            guard let nc = nc else {return}
            let coordinator = CreateOrRestoreWallet.Coordinator(navigationController: nc)
            self?.setChildCoordinator(coordinator)
        }
    }
    
    private func showOnboardingScene(completion: (() -> Void)?) {
        let vc = Onboarding.ViewController()
        changeRootViewController(to: vc, completion: completion)
    }
    
    private func showWelcomeScene(isRestoration: Bool, name: String?, completion: (() -> Void)?) {
        let vc = WelcomeViewController(isReturned: isRestoration, name: name)
        changeRootViewController(to: vc, completion: nil)
    }
    
    private func showMainScene(withAuthentication: Bool, completion: (() -> Void)? = nil) {
        // MainViewController
        let vc = MainViewController()
        vc.authenticateWhenAppears = withAuthentication
        changeRootViewController(to: vc, completion: completion)
    }
    
    // MARK: - Helpers
    private func changeRootViewController(to vc: UIViewController, completion: (() -> Void)?) {
        // TODO: - Animation
        window?.rootViewController = PlaceholderViewController()
        
        // wait 300 ms for process of relacing rootViewController to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
            self?.window?.rootViewController = vc
            completion?()
        }
    }
    
    private func setChildCoordinator(_ coordinator: CoordinatorType) {
        // release coordinator when finished
        coordinator.didCancel = {[weak self] _ in
            self?.childCoordinator = nil
        }
        
        // start coordinator
        coordinator.start()

        // keep reference to coordinator
        childCoordinator = coordinator
    }
}

extension AppCoordinator: AppEventHandlerDelegate {
    func createWalletDidComplete() {
        isRestoration = false
        analyticsManager.log(event: .setupOpen(fromPage: "create_wallet"))
        showOnboardingScene(completion: nil)
    }
    
    func restoreWalletDidComplete() {
        isRestoration = true
        analyticsManager.log(event: .setupOpen(fromPage: "recovery"))
        showOnboardingScene(completion: nil)
    }
    
    func onboardingDidFinish(resolvedName: String?) {
        let event: AnalyticsEvent = isRestoration ? .setupWelcomeBackOpen: .setupFinishOpen
        analyticsManager.log(event: event)
        showWelcomeScene(isRestoration: isRestoration, name: resolvedName, completion: nil)
    }
    
    func userDidTapStartUsingP2PWallet() {
        analyticsManager.log(event: .setupFinishClick)
        showMainScene(withAuthentication: false, completion: nil)
    }
    
    func userDidChangeAPIEndpoint(to endpoint: SolanaSDK.APIEndPoint) {
        // reload
        start(authenticateOnMain: false)
    }
    
    func userDidChangeLanguage(to language: LocalizedLanguage) {
        // reload
        start(authenticateOnMain: false)
    }
    
    func userDidLogout() {
        // reload
        start(authenticateOnMain: false)
    }
}
