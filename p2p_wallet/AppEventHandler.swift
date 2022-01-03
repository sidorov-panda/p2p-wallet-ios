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

final class AppEventHandler: AppEventHandlerType {
    // MARK: - Properties
    var reloadHandler: (() -> Void)?
    private let isLoadingSubject = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Handlers
    var isLoadingDriver: Driver<Bool> {
        isLoadingSubject.asDriver()
    }
    
    func creatingWalletDidComplete(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?) {
        <#code#>
    }
    
    func restoringWalletDidComplete(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?) {
        <#code#>
    }
    
    func creatingOrRestoringWalletDidCancel() {
        <#code#>
    }
    
    func onboardingDidCancel() {
        <#code#>
    }
    
    func onboardingDidComplete() {
        <#code#>
    }
    
    func requiredOwner(onSuccess: (() -> Void)?, onFailure: ((String?) -> Void)?) {
        <#code#>
    }
    
    func changeAPIEndpoint(to endpoint: SolanaSDK.APIEndPoint) {
        <#code#>
    }
    
    func languageDidChange(to: LocalizedLanguage) {
        <#code#>
    }
    
    func logout() {
        <#code#>
    }
}
