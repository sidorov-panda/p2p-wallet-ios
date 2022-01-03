//
//  AppEventHandler.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/01/2022.
//

import Foundation
import RxCocoa
import LocalAuthentication

protocol AppEventHandlerType: CreateOrRestoreWalletHandler,
                                OnboardingHandler,
                                DeviceOwnerAuthenticationHandler,
                                ChangeNetworkResponder,
                                ChangeLanguageResponder,
                                LogoutResponder
{
    var isLoadingDriver: Driver<Bool> {get}
    var delegate: AppEventHandlerDelegate? {get set}
}

protocol AppEventHandlerDelegate: AnyObject {
    func createWalletDidComplete()
    func restoreWalletDidComplete()
    
    func onboardingDidFinish(resolvedName: String?)
    
    func userDidChangeAPIEndpoint(to endpoint: SolanaSDK.APIEndPoint)
    func userDidChangeLanguage(to language: LocalizedLanguage)
    func userDidLogout()
}

final class AppEventHandler: AppEventHandlerType {
    // MARK: - Dependencies
    private let storage: AccountStorageType & PincodeStorageType & NameStorageType = Resolver.resolve()
    private let notificationsService: NotificationsServiceType = Resolver.resolve()
    
    // MARK: - Properties
    private let isLoadingSubject = BehaviorRelay<Bool>(value: false)
    weak var delegate: AppEventHandlerDelegate?
    private var resolvedName: String?
    
    // MARK: - Handlers
    var isLoadingDriver: Driver<Bool> {
        isLoadingSubject.asDriver()
    }
    
    // MARK: - Create or restore wallet
    func createWallet(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?) {
        saveAccountToStorage(phrases: phrases, derivablePath: derivablePath, name: name) { [weak self] in
            self?.delegate?.createWalletDidComplete()
        }
    }
    
    func restoreWallet(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?) {
        saveAccountToStorage(phrases: phrases, derivablePath: derivablePath, name: name) { [weak self] in
            self?.delegate?.restoreWalletDidComplete()
        }
    }
    
    func cancelCreatingOrRestoringWallet() {
        logout()
    }
    
    // MARK: - Onboarding
    func finishOnboarding() {
        delegate?.onboardingDidFinish(resolvedName: resolvedName)
    }
    
    func cancelOnboarding() {
        logout()
    }
    
    // MARK: - Owner verification
    func requiredOwner(onSuccess: (() -> Void)?, onFailure: ((String?) -> Void)?) {
        let myContext = LAContext()
        
        var error: NSError?
        guard myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            DispatchQueue.main.async {
                onFailure?(errorToString(error))
            }
            return
        }
        
        myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: L10n.confirmItSYou) { (success, error) in
            guard success else {
                DispatchQueue.main.async {
                    onFailure?(errorToString(error))
                }
                return
            }
            DispatchQueue.main.sync {
                onSuccess?()
            }
        }
    }
    
    // MARK: - Change API Endpoint
    func changeAPIEndpoint(to endpoint: SolanaSDK.APIEndPoint) {
        Defaults.apiEndPoint = endpoint
//        showAuthenticationOnMainOnAppear = false
        ResolverScope.session.reset()
        delegate?.userDidChangeAPIEndpoint(to: endpoint)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.notificationsService.showInAppNotification(.done(L10n.networkChanged))
        }
    }
    
    // MARK: - Change language
    func languageDidChange(to language: LocalizedLanguage) {
        UIApplication.languageChanged()
//        showAuthenticationOnMainOnAppear = false
        delegate?.userDidChangeLanguage(to: language)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            let languageChangedText = language.originalName.map(L10n.changedLanguageTo) ?? L10n.interfaceLanguageChanged
            self?.notificationsService.showInAppNotification(.done(languageChangedText))
        }
    }
    
    // MARK: - Logout
    func logout() {
        ResolverScope.session.reset()
        storage.clearAccount()
        Defaults.walletName = [:]
        Defaults.didSetEnableBiometry = false
        Defaults.didSetEnableNotifications = false
        Defaults.didBackupOffline = false
        Defaults.renVMSession = nil
        Defaults.renVMProcessingTxs = []
        Defaults.forceCloseNameServiceBanner = false
        Defaults.shouldShowConfirmAlertOnSend = true
        Defaults.shouldShowConfirmAlertOnSwap = true
        delegate?.userDidLogout()
    }
}

// MARK: - Helpers
private extension AppEventHandler {
    private func saveAccountToStorage(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?, completion: (() -> Void)?) {
        guard let phrases = phrases, let derivablePath = derivablePath else {
            cancelCreatingOrRestoringWallet()
            return
        }
        resolvedName = name
        
        isLoadingSubject.accept(true)
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.storage.save(phrases: phrases)
                try self?.storage.save(derivableType: derivablePath.type)
                try self?.storage.save(walletIndex: derivablePath.walletIndex)
                
                if let name = name {
                    self?.storage.save(name: name)
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.isLoadingSubject.accept(false)
                    completion?()
                }
            } catch {
                self?.isLoadingSubject.accept(false)
                DispatchQueue.main.async { [weak self] in
                    self?.notificationsService.showInAppNotification(.error(error))
                    self?.cancelCreatingOrRestoringWallet()
                }
            }
        }
    }
}

private func errorToString(_ error: Error?) -> String? {
    var error = error?.localizedDescription ?? L10n.unknownError
    switch error {
    case "Passcode not set.":
        error = L10n.PasscodeNotSet.soWeCanTVerifyYouAsTheDeviceSOwner
    case "Canceled by user.":
        return nil
    default:
        break
    }
    return error
}
