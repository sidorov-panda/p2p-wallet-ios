//
//  OrcaSwapV2.ConfirmViewController.swift
//  p2p_wallet
//
//  Created by Chung Tran on 15/12/2021.
//

import Foundation

extension OrcaSwapV2 {
    final class ConfirmViewController: BaseVC {
        override var preferredNavigationBarStype: BEViewController.NavigationBarStyle {
            .hidden
        }
        
        // MARK: - Properties
        private let viewModel: OrcaSwapV2ViewModelType
        
        // MARK: - Subviews
        private lazy var navigationBar: WLNavigationBar = {
            let navigationBar = WLNavigationBar(forAutoLayout: ())
            navigationBar.backButton.onTap(self, action: #selector(back))
            return navigationBar
        }()
        
        private lazy var rootView = ConfirmRootView(viewModel: viewModel)
        
        // MARK: - Methods
        init(viewModel: OrcaSwapV2ViewModelType) {
            self.viewModel = viewModel
            super.init()
        }
        
        override func setUp() {
            super.setUp()
            view.addSubview(navigationBar)
            navigationBar.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
            
            view.addSubview(rootView)
            rootView.autoPinEdge(.top, to: .bottom, of: navigationBar, withOffset: 8)
            rootView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        }
    }
}

extension OrcaSwapV2 {
    final class ConfirmRootView: ScrollableVStackRootView {
        // MARK: - Properties
        private let viewModel: OrcaSwapV2ViewModelType
        
        // MARK: - Initializers
        init(viewModel: OrcaSwapV2ViewModelType) {
            self.viewModel = viewModel
            super.init()
            scrollView.contentInset = .init(top: 8, left: 18, bottom: 18, right: 18)
            setUp()
        }
        
        func setUp() {
            stackView.addArrangedSubviews {
                UIView.greyBannerView(axis: .horizontal, spacing: 12, alignment: .top) {
                    UILabel(
                        text: L10n.BeSureAllDetailsAreCorrectBeforeConfirmingTheTransaction
                            .onceConfirmedItCannotBeReversed,
                        textSize: 15,
                        numberOfLines: 0
                    )
                    UIView.closeBannerButton()
                        .onTap(self, action: #selector(closeBannerButtonDidTouch))
                }
            }
        }
        
        // MARK: - Action
        @objc private func closeBannerButtonDidTouch() {
            
        }
    }
}