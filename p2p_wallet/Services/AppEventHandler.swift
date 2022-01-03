//
//  AppEventHandler.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/01/2022.
//

import Foundation
import RxCocoa

protocol AppEventHandlerType: CreateOrRestoreWalletHandler,
                                OnboardingHandler,
                                DeviceOwnerAuthenticationHandler,
                                ChangeNetworkResponder,
                                ChangeLanguageResponder,
                                LogoutResponder
{
    var reloadHandler: (() -> Void)? {get set}
    var isLoadingDriver: Driver<Bool> {get}
}

protocol AppEventHandlerDelegate: AnyObject {
    func createWalletDidComplete()
    func restoreWalletDidComplete()
    func createOrRestoreWalletDidCancel()
    
    func onboardingDidFinish()
    func onboardingDidCancel()
    
    func userDidChangeAPIEndpoint(to endpoint: SolanaSDK.APIEndPoint)
    func userDidChangeLanguage(to language: LocalizedLanguage)
}

final class AppEventHandler: AppEventHandlerType {
    // MARK: - Properties
    var reloadHandler: (() -> Void)?
    private let isLoadingSubject = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Handlers
    var isLoadingDriver: Driver<Bool> {
        isLoadingSubject.asDriver()
    }
    
    // MARK: - Create or restore wallet
    func createWallet(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?) {
        <#code#>
    }
    
    func restoreWallet(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?) {
        <#code#>
    }
    
    func cancelCreatingOrRestoringWallet() {
        <#code#>
    }
    
    // MARK: - Onboarding
    func finishOnboarding() {
        <#code#>
    }
    
    func cancelOnboarding() {
        <#code#>
    }
    
    // MARK: - Owner verification
    func requiredOwner(onSuccess: (() -> Void)?, onFailure: ((String?) -> Void)?) {
        <#code#>
    }
    
    // MARK: - Change API Endpoint
    func changeAPIEndpoint(to endpoint: SolanaSDK.APIEndPoint) {
        <#code#>
    }
    
    // MARK: - Change language
    func languageDidChange(to: LocalizedLanguage) {
        <#code#>
    }
    
    // MARK: - Logout
    func logout() {
        <#code#>
    }
}
