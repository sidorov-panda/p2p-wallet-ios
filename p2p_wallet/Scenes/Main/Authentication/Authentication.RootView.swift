//
//  Authentication.RootView.swift
//  p2p_wallet
//
//  Created by Chung Tran on 12/11/2021.
//

import UIKit
import RxSwift

extension Authentication {
    class RootView: BEView {
        // MARK: - Constants
        let disposeBag = DisposeBag()
        
        // MARK: - Properties
        @Injected private var viewModel: AuthenticationViewModelType
        
        // MARK: - Subviews
        
        // MARK: - Methods
        override func commonInit() {
            super.commonInit()
            layout()
            bind()
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
        }
        
        // MARK: - Layout
        private func layout() {
            
        }
        
        private func bind() {
            
        }
    }
}
