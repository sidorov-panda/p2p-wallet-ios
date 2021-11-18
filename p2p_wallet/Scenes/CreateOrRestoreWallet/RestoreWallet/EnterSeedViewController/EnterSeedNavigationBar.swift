//
//  EnterSeedNavigationBar.swift
//  p2p_wallet
//
//  Created by Andrew Vasiliev on 11.11.2021.
//

import UIKit

final class EnterSeedNavigationBar: WLNavigationBar {
    private let backHandler: () -> Void
    private let infoHandler: () -> Void

    init(
        backHandler: @escaping () -> Void,
        infoHandler: @escaping () -> Void
    ) {
        self.backHandler = backHandler
        self.infoHandler = infoHandler

        super.init(frame: .zero)

        configureSelf()
    }

    private func configureSelf() {
        backButton.onTap(self, action: #selector(back))
        titleLabel.text = L10n.enterYourSecurityKey
        let infoButton = UIButton(width: 24, height: 24)
        infoButton.setImage(.info, for: .normal)
        infoButton.addTarget(self, action: #selector(info), for: .touchUpInside)
        rightItems.addArrangedSubview(infoButton)
    }

    @objc
    func back() {
        backHandler()
    }

    @objc
    func info() {
        infoHandler()
    }
}