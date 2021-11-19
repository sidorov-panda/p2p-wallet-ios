//
//  CreateSecurityKeys.ViewModel.swift
//  p2p_wallet
//
//  Created by Chung Tran on 22/02/2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol CreateSecurityKeysViewModelType {
    var showTermsAndConditionsSignal: Signal<Void> { get }
    var phrasesDriver: Driver<[String]> { get }
    var errorSignal: Signal<String> { get }
    
    func copyToClipboard()
    func renewPhrases()
    
    func showTermsAndConditions()
    func saveToICloud()
    func back()
    func verifyPhrase()
}

extension CreateSecurityKeys {
    class ViewModel {
        // MARK: - Dependencies
        @Injected private var iCloudStorage: ICloudStorageType
        @Injected private var analyticsManager: AnalyticsManagerType
        @Injected private var createWalletViewModel: CreateWalletViewModelType
        @Injected private var authenticationHandler: AuthenticationHandler
        
        // MARK: - Properties
        private let disposeBag = DisposeBag()
        
        // MARK: - Subjects
        private let showTermsAndConditionsSubject = PublishRelay<Void>()
        private let phrasesSubject = BehaviorRelay<[String]>(value: [])
        private let errorSubject = PublishRelay<String>()
        
        // MARK: - Initializer
        init() {
            createPhrases()
        }
        
        private func createPhrases() {
            let mnemonic = Mnemonic()
            phrasesSubject.accept(mnemonic.phrase)
        }
    }
}

extension CreateSecurityKeys.ViewModel: CreateSecurityKeysViewModelType {
    var showTermsAndConditionsSignal: Signal<Void> {
        showTermsAndConditionsSubject.asSignal()
    }
    
    var phrasesDriver: Driver<[String]> {
        phrasesSubject.asDriver()
    }
    
    var errorSignal: Signal<String> {
        errorSubject.asSignal()
    }
    
    // MARK: - Actions
    func showTermsAndConditions() {
        analyticsManager.log(event: .createWalletTermsAndConditionsClick)
        showTermsAndConditionsSubject.accept(())
    }
    
    func renewPhrases() {
        analyticsManager.log(event: .createWalletRenewSeedClick)
        createPhrases()
    }
    
    func copyToClipboard() {
        analyticsManager.log(event: .createWalletCopySeedClick)
        UIApplication.shared.copyToClipboard(phrasesSubject.value.joined(separator: " "), alertMessage: L10n.seedPhraseCopiedToClipboard)
    }
    
    @objc func saveToICloud() {
        authenticationHandler.requiredOwner { [weak self] in
            self?._saveToIcloud()
        } onFailure: { [weak self] error in
            self?.errorSubject.accept(error?.localizedDescription ?? L10n.error)
        }
    }
    
    private func _saveToIcloud() {
        analyticsManager.log(event: .createWalletBackupToIcloudClick)
        let result = iCloudStorage.saveToICloud(
            account: .init(
                name: nil,
                phrase: phrasesSubject.value.joined(separator: " "),
                derivablePath: .default
            )
        )
        
        if result {
            UIApplication.shared.showToast(message: "✅ " + L10n.savedToICloud)
            createWalletViewModel.handlePhrases(phrasesSubject.value)
        } else {
            errorSubject.accept(L10n.SecurityKeyCanTBeSavedIntoIcloud.pleaseTryAgain)
        }
    }
    
    func verifyPhrase() {
        analyticsManager.log(event: .createWalletVerifyManuallyClick)
        createWalletViewModel.verifyPhrase(phrasesSubject.value)
    }
    
    @objc func back() {
        createWalletViewModel.back()
    }
}
