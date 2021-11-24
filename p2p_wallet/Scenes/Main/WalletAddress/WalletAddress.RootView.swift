//
//  WalletAddress.RootView.swift
//  p2p_wallet
//
//  Created by Giang Long Tran on 22.11.21.
//

import UIKit
import RxSwift

extension WalletAddress {
    class RootView: BEView {
        // MARK: - Constants
        let disposeBag = DisposeBag()
        
        // MARK: - Properties
        @Injected private var viewModel: WalletAddressViewModelType
        
        // MARK: - Subviews
        lazy var navigationBar: WLNavigationBar = {
            let navigationBar = WLNavigationBar(height: 55, backgroundColor: .fafafc)
//            navigationBar.backButton.onTap(self, action: #selector(back))
            return navigationBar
        }()
        
        private let qrCode = ReceiveToken.QrCodeView(size: 237, coinLogoSize: 44)
        
        fileprivate let copyButton: UIButton = UIButton.text(text: L10n.copy, image: .copyIcon, tintColor: .h5887ff)
        fileprivate let shareButton: UIButton = UIButton.text(text: L10n.share, image: .share2, tintColor: .h5887ff)
        fileprivate let saveButton: UIButton = UIButton.text(text: L10n.save, image: .imageIcon, tintColor: .h5887ff)
        
        private let walletAddressLabel = UILabel(numberOfLines: 2, textAlignment: .right)
        private let directAddressLabel = UILabel(numberOfLines: 2, textAlignment: .right)
        private let mintAddressLabel = UILabel(numberOfLines: 2, textAlignment: .right)
        
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
            let navStack = UIStackView(axis: .vertical, alignment: .fill) {
                navigationBar
                UIView.defaultSeparator()
            }
            addSubview(navStack)
            navStack.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            
            let scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
            addSubview(scrollView)
            scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            scrollView.autoPinEdge(.top, to: .bottom, of: navStack)
            
            var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill) {
                // Navigation bar
                
                // QR Section
                UIStackView(axis: .vertical, alignment: .fill) {
                    qrCode.autoAdjustWidthHeightRatio(1)
                        .padding(.init(x: 50, y: 33))
                    UIView.defaultSeparator()
                    UIStackView(axis: .horizontal, alignment: .fill, distribution: .fillEqually) {
                        copyButton
                        shareButton
                        saveButton
                    }.padding(.init(x: 0, y: 4))
                }.border(width: 1, color: .f2f2f7)
                    .box(cornerRadius: 12)
                    .shadow(color: .black, alpha: 0.05, y: 1, blur: 8)
                    .margin(.init(x: 0, y: 18))
                
                // Tap and hold to copy
                UIStackView(axis: .horizontal, alignment: .center) {
                    UIImageView(image: .alertOutlined)
                        .autoAdjustWidthHeightRatio(1)
                        .padding(.init(only: .left, inset: 18))
                        .padding(.init(only: .right, inset: 24))
                    UILabel(text: L10n.tapAndHoldToCopy)
                    UIImageView(image: .cross).autoAdjustWidthHeightRatio(1)
                        .padding(.init(only: .right, inset: 18))
                }.backgroundColor(color: .fafafc)
                    .box(cornerRadius: 12)
                    .frame(height: 60)
                
                // Wallet address
                BEStackViewSpacing(18)
                addressView(title: L10n.walletAddress, labelView: walletAddressLabel)
                UIView.defaultSeparator()
                
                // direct SOL address
                addressView(title: L10n.walletAddress, labelView: directAddressLabel)
                UIView.defaultSeparator()
                
                // mint address
                addressView(title: L10n.mintAddress, labelView: mintAddressLabel)
                
                BEStackViewSpacing(18)
                WLButton.stepButton(type: .blue, label: L10n.viewInExplorer(L10n.solana))
            }.padding(.init(x: 18, y: 0))
            
            scrollView.contentView.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges()

//            addSubview(qrCode)
//            qrCode.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
//            qrCode.autoAdjustWidthHeightRatio(1)
        }
        
        private func addressView(title: String, labelView: UIView) -> UIView {
            UIStackView(axis: .horizontal, alignment: .fill) {
                UILabel(text: title, textColor: .h8e8e93, numberOfLines: 2).frame(width: 70)
                BEStackViewSpacing(12)
                labelView
            }.frame(height: 78)
        }
        
        private func bind() {
            viewModel.walletDriver.map { wallet in wallet?.name }.drive(navigationBar.titleLabel.rx.text).disposed(by: disposeBag)
            viewModel.walletDriver.map { wallet in wallet?.pubkey }.drive(walletAddressLabel.rx.text).disposed(by: disposeBag)
            viewModel.solanaAddressDriver.drive(directAddressLabel.rx.text).disposed(by: disposeBag)
            viewModel.walletDriver.map { wallet in wallet?.mintAddress }.drive(mintAddressLabel.rx.text).disposed(by: disposeBag)
            viewModel.walletDriver.drive(qrCode.rx.wallet).disposed(by: disposeBag)
        }
        
        // MARK: - Actions
        
    }
}
