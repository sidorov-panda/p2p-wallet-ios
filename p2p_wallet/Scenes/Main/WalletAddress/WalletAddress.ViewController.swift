//
//  WalletAddress.ViewController.swift
//  p2p_wallet
//
//  Created by Giang Long Tran on 22.11.21.
//

import Foundation
import UIKit

extension WalletAddress {
    class ViewController: BaseVC {
        
        // MARK: - Dependencies
        @Injected private var viewModel: WalletAddressViewModelType
        
        // MARK: - Properties
        
        // MARK: - Methods
        
        init(wallet: Wallet) {
            super.init()
            viewModel.setup(wallet: wallet)
        }
        
        override func loadView() {
            view = WalletAddress.RootView()
        }
        
        override func setUp() {
            super.setUp()
            
        }
        
        override func bind() {
            super.bind()

//            viewModel.navigationDriver
//                .drive(onNext: { [weak self] in self?.navigate(to: $0) })
//                .disposed(by: disposeBag)
        }
        
        // MARK: - Navigation
//        private func navigate(to scene: NavigatableScene?) {
//            guard let scene = scene else { return }
//            switch scene {}
//         }
    }
}
