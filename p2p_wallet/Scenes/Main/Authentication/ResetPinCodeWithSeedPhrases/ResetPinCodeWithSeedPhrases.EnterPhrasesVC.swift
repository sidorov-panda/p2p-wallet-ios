//
//  ResetPinCodeWithSeedPhrases.EnterPhrasesVC.swift
//  p2p_wallet
//
//  Created by Chung Tran on 28/06/2021.
//

import BEPureLayout
import RxCocoa
import RxSwift
import UIKit

extension ResetPinCodeWithSeedPhrases {
    class EnterPhrasesVC: BEScene {
        override var preferredNavigationBarStype: NavigationBarStyle { .hidden }
        private let completion: ([String]) -> Void
        private let validate: (_ keyPhrase: [String]) -> (status: Bool, error: String?)
        var dismissAfterCompletion = true

        private let pastButton = BERef<UIButton>()
        private let inputTextField = BERef<ExpandableTextView>()

        enum ButtonState {
            case enter
            case reset(_ keyPhrase: [String])
            case error(_ message: String)
        }

        private let buttonState = BehaviorSubject<ButtonState>(value: .enter)

        init(
            completion: @escaping ([String]) -> Void,
            validate: @escaping ([String]) -> (status: Bool, error: String?)
        ) {
            self.completion = completion
            self.validate = validate
            super.init()
        }

        override func build() -> UIView {
            BESafeArea {
                BEZStack {
                    // Content
                    BEZStackPosition(mode: .fill) {
                        BEVStack {
                            BEHStack(distribution: .equalCentering) {
                                UIButton.text(text: L10n.cancel, fontSize: 17, weight: .regular, tintColor: .h5887ff)
                                    .setTarget(target: self, action: #selector(back), for: .touchUpInside)

                                UILabel(
                                    text: L10n.resettingYourPIN,
                                    textSize: 17,
                                    weight: .semibold,
                                    textAlignment: .center
                                )

                                UIView(width: 24)
                            }
                            .backgroundColor(color: .fafafc)
                            .frame(height: 58)

                            // Separator
                            UIView.separator(height: 1, color: .separator)

                            // Input
                            BEHStack {
                                ExpandableTextView()
                                    .setup { textField in
                                        textField.placeholder = L10n.yourSecurityKey

                                        textField.rxText
                                            .bind { [weak self] text in
                                                guard let self = self else { return }
                                                let text = text ?? ""
                                                self.pastButton.isHidden = text.count > 0

                                                if text.isEmpty {
                                                    self.buttonState.on(.next(.enter))
                                                } else {
                                                    let keyPhrase = text.trimmingCharacters(in: .whitespacesAndNewlines)
                                                        .components(separatedBy: " ")
                                                    let (status, error) = self.validate(keyPhrase)
                                                    self.buttonState
                                                        .on(.next(status ? .reset(keyPhrase) :
                                                                .error(error ?? L10n.error)))
                                                }
                                            }
                                            .disposed(by: disposeBag)
                                    }
                                    .bind(inputTextField)
                                    .withTag(1)
                                UIButton(
                                    label: L10n.paste,
                                    labelFont: .systemFont(ofSize: 17, weight: .medium),
                                    textColor: .h5887ff
                                ).bind(pastButton)
                                    .setTarget(target: self, action: #selector(past), for: .touchUpInside)
                                    .frame(width: 78)
                                    .withTag(2)
                            }
                            .setup { view in
                                guard
                                    let v1 = view.viewWithTag(1),
                                    let v2 = view.viewWithTag(2)
                                else { return }

                                v2.autoMatch(.height, to: .height, of: v1)
                            }
                            .padding(.init(top: 8, left: 18, bottom: 8, right: 18))

                            // Separator
                            UIView
                                .separator(height: 1, color: .separator)
                                .padding(.init(x: 18, y: 0))

                            UIView.spacer
                        }
                    }

                    // Button
                    BEZStackPosition(mode: .pinEdges([.bottom, .left, .right], avoidKeyboard: true)) {
                        BEBuilder(driver: buttonState.asDriver(onErrorJustReturn: .enter)) { state in
                            switch state {
                            case .enter:
                                let button = WLStepButton.main(text: L10n.enterYourSecurityKey)
                                button.isEnabled = false
                                return button
                            case let .reset(keyPhrase):
                                let button = WLStepButton.main(text: L10n.resetYourPIN)
                                    .onTap { [unowned self] in completion(keyPhrase) }
                                return button
                            case let .error(message):
                                let button = WLStepButton.main(text: message)
                                button.isEnabled = false
                                return button
                            }
                        }.padding(.init(x: 18, y: 18))
                    }
                }
            }
        }

        @objc func past() {
            let clipboard = Resolver.resolve(ClipboardManager.self)
            inputTextField.view?.set(text: clipboard.stringFromClipboard())
        }
    }
}
