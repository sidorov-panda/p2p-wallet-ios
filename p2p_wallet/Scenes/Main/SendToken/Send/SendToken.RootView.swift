//
//  SendRootView.swift
//  p2p_wallet
//
//  Created by Chung Tran on 01/06/2021.
//

import UIKit
import RxSwift

extension SendToken {
    class RootView: ScrollableVStackRootView {
        // MARK: - Constants
        let disposeBag = DisposeBag()
        
        // MARK: - Properties
        let viewModel: ViewModel
        
        // MARK: - Subviews
        lazy var balanceLabel = UILabel(text: "0", weight: .medium)
            .onTap(viewModel, action: #selector(ViewModel.useAllBalance))
        lazy var coinImageView = CoinLogoImageView(size: 44)
            .onTap(viewModel, action: #selector(ViewModel.chooseWallet))
        lazy var amountTextField = TokenAmountTextField(
            font: .systemFont(ofSize: 27, weight: .semibold),
            textColor: .textBlack,
            keyboardType: .decimalPad,
            placeholder: "0\(Locale.current.decimalSeparator ?? ".")0",
            autocorrectionType: .no
        )
        lazy var changeModeButton = UILabel(weight: .semibold, textColor: .textSecondary)
            .onTap(viewModel, action: #selector(ViewModel.switchCurrencyMode))
        lazy var symbolLabel = UILabel(weight: .semibold)
        lazy var equityValueLabel = UILabel(text: "≈", textColor: .textSecondary)
        lazy var coinSymbolPriceLabel = UILabel(textColor: .textSecondary)
        lazy var coinPriceLabel = UILabel(textColor: .textSecondary)
        
        lazy var addressStackView = UIStackView(axis: .horizontal, spacing: 0, alignment: .center, distribution: .fill, arrangedSubviews: [
            walletIconView, addressTextField, clearAddressButton, qrCodeImageView
        ])
        lazy var walletIconView = UIImageView(width: 24, height: 24, image: .walletIcon, tintColor: .a3a5ba)
            .padding(.init(all: 10), backgroundColor: .textWhite, cornerRadius: 12)
        lazy var addressTextField = UITextField(height: 44, backgroundColor: .clear, placeholder: L10n.walletAddress, autocorrectionType: .none, autocapitalizationType: UITextAutocapitalizationType.none, spellCheckingType: .no, horizontalPadding: 8)
        lazy var clearAddressButton = UIImageView(width: 24, height: 24, image: .closeFill, tintColor: UIColor.black.withAlphaComponent(0.6))
            .onTap(viewModel, action: #selector(ViewModel.clearDestinationAddress))
        lazy var qrCodeImageView = UIImageView(width: 35, height: 35, image: .scanQr3, tintColor: .a3a5ba)
            .onTap(viewModel, action: #selector(ViewModel.scanQrCode))
        lazy var errorLabel = UILabel(text: " ", textSize: 12, weight: .medium, textColor: .red, numberOfLines: 0, textAlignment: .center)
        
        lazy var feeLabel = LazyLabel<Double>(textColor: .textSecondary)
        
        lazy var feeInfoButton = UIImageView(width: 16.67, height: 16.67, image: .infoCircle, tintColor: .a3a5ba)
            .onTap(viewModel, action: #selector(ViewModel.showFeeInfo))
        
        lazy var sendButton = WLButton.stepButton(type: .blue, label: L10n.sendNow)
            .onTap(viewModel, action: #selector(ViewModel.authenticateAndSend))
        
        // MARK: - Initializers
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(frame: .zero)
        }
        
        // MARK: - Methods
        override func commonInit() {
            super.commonInit()
            layout()
            bind()
            amountTextField.delegate = self
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
        }
        
        // MARK: - Layout
        private func layout() {
            stackView.addArrangedSubviews([
                UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .equalSpacing, arrangedSubviews: [
                    UILabel(text: L10n.from, weight: .bold),
                    balanceLabel
                ]),
                BEStackViewSpacing(30),
                
                UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill, arrangedSubviews: [
                    coinImageView,
                    UIImageView(width: 11, height: 8, image: .downArrow, tintColor: .textBlack)
                        .onTap(viewModel, action: #selector(SendTokenViewModel.chooseWallet)),
                    amountTextField,
                    changeModeButton
                        .withContentHuggingPriority(.required, for: .horizontal)
                        .padding(.init(all: 10), backgroundColor: .f6f6f8, cornerRadius: 12)
                ]),
                BEStackViewSpacing(6),
                
                UIStackView(axis: .horizontal, spacing: 0, alignment: .center, distribution: .fill, arrangedSubviews: [
                    UIView(),
                    equityValueLabel
                ]),
                BEStackViewSpacing(20),
                
                UIView.separator(height: 1, color: .separator),
                BEStackViewSpacing(20),
                
                UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill) {
                    UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .equalSpacing) {
                        coinSymbolPriceLabel
                        coinPriceLabel
                    }
                    
                    UIStackView(axis: .horizontal, spacing: 6.67, alignment: .center, distribution: .fill) {
                        UILabel(text: L10n.fee + ":", textColor: .textSecondary)
                        feeLabel
                            .withContentHuggingPriority(.required, for: .horizontal)
                        feeInfoButton
                            .withContentHuggingPriority(.required, for: .horizontal)
                    }
                },
                
                BEStackViewSpacing(20),
                
                UIView.separator(height: 1, color: .separator),
                BEStackViewSpacing(20),
                
                UILabel(text: L10n.sendTo, weight: .bold),
                addressStackView
                    .padding(.init(all: 8), backgroundColor: UIColor.a3a5ba.withAlphaComponent(0.1), cornerRadius: 12),
                
                BEStackViewSpacing(19),
                
                errorLabel,
                
                BEStackViewSpacing(20),
                UIView.separator(height: 1, color: .separator),
                BEStackViewSpacing(20),
                
                sendButton
            ])
            
            equityValueLabel.autoPinEdge(.leading, to: .leading, of: amountTextField)
            
            scrollView.contentView.addSubview(symbolLabel)
            symbolLabel.centerXAnchor.constraint(equalTo: coinImageView.centerXAnchor).isActive = true
            symbolLabel.centerYAnchor.constraint(equalTo: equityValueLabel.centerYAnchor).isActive = true
            
            feeInfoButton.isHidden = !Defaults.useFreeTransaction
        }
        
        private func bind() {
            // textfield
        }
    }
}

extension SendToken.RootView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textField = textField as? TokenAmountTextField {
            return textField.shouldChangeCharactersInRange(range, replacementString: string)
        }
        return true
    }
}
