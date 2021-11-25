//
//  WalletAddress.ViewModel.swift
//  p2p_wallet
//
//  Created by Giang Long Tran on 22.11.21.
//

import Foundation
import RxSwift
import RxCocoa
import SolanaSwift

protocol WalletAddressViewModelType {
    var walletDriver: Driver<Wallet?> { get }
    
    var navigationDriver: Driver<WalletAddress.NavigatableScene?> { get }
    func navigate(to scene: WalletAddress.NavigatableScene)
    
    func setup(wallet: Wallet)
}

extension WalletAddress {
    class ViewModel {
        // MARK: - Dependencies
        @Injected private var nameService: NameServiceType
        
        // MARK: - Properties
        private let walletSubject = BehaviorRelay<SolanaSDK.Wallet?>(value: nil)
        
        // MARK: - Subject
        private let navigationSubject = BehaviorRelay<NavigatableScene?>(value: nil)
    }
}

extension WalletAddress.ViewModel: WalletAddressViewModelType {
    func setup(wallet: Wallet) {
        walletSubject.accept(wallet)
    }
    
    var walletDriver: Driver<Wallet?> {
        walletSubject.asDriver()
    }
    
    var navigationDriver: Driver<WalletAddress.NavigatableScene?> {
        navigationSubject.asDriver()
    }
    
    // MARK: - Actions
    func navigate(to scene: WalletAddress.NavigatableScene) {
        navigationSubject.accept(scene)
    }
}
