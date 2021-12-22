//
//  BuyRoot.ViewModel.swift
//  p2p_wallet
//
//  Created by Giang Long Tran on 16.12.21.
//

import Foundation
import RxSwift
import RxCocoa

protocol BuyViewModelType {
    var walletRepository: WalletsRepository { get }
    var navigationDriver: Driver<BuyRoot.NavigatableScene> { get }
    
    func navigate(to scene: BuyRoot.NavigatableScene)
}

extension BuyRoot {
    class ViewModel: NSObject {
        // MARK: - Dependencies
        
        // MARK: - Properties
        let walletRepository: WalletsRepository
        
        init(walletRepository: WalletsRepository) {
            self.walletRepository = walletRepository
        }
        
        // MARK: - Subject
        private let navigationSubject = PublishSubject<NavigatableScene>()
    }
}

extension BuyRoot.ViewModel: BuyViewModelType {
    var navigationDriver: Driver<BuyRoot.NavigatableScene> {
        navigationSubject.asDriver(onErrorJustReturn: .none)
    }
    
    // MARK: - Actions
    func navigate(to scene: BuyRoot.NavigatableScene) {
        navigationSubject.onNext(scene)
    }
}