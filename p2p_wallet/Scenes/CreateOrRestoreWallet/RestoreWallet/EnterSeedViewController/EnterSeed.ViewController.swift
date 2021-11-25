//
//  EnterSeed.ViewController.swift
//  p2p_wallet
//
//  Created by Andrew Vasiliev on 11.11.2021.
//

import Resolver
import UIKit
import RxSwift

extension EnterSeed {
    class ViewController: BaseVC {
        override var preferredNavigationBarStype: BEViewController.NavigationBarStyle {
            .hidden
        }

        // MARK: - Dependencies
        private let viewModel: EnterSeedViewModelType
        
        // MARK: - Properties
        private lazy var rootView = RootView(viewModel: viewModel)
        
        // MARK: - Methods
        init(viewModel: EnterSeedViewModelType) {
            self.viewModel = viewModel
        }

        override func loadView() {
            view = rootView
        }
        
        override func setUp() {
            super.setUp()
        }

        override func bind() {
            super.bind()
            viewModel.navigationDriver
                .drive(onNext: { [weak self] in
                    self?.navigate(to: $0)
                })
                .disposed(by: disposeBag)
        }

        override func viewDidAppear(_ animated: Bool) {
            rootView.startTyping()
        }

        // MARK: - Navigation
        private func navigate(to scene: NavigatableScene?) {
            switch scene {
            case .none:
                break
            case .info:
                let vc = EnterSeedInfo.ViewController(viewModel: Resolver.resolve())
                present(vc, animated: true)
            case .back:
                navigationController?.popViewController(animated: true)
            case let .success(words):
                let viewModel = DerivableAccounts.ViewModel(phrases: words)
                let vc = DerivableAccounts.ViewController(viewModel: viewModel)
                navigationController?.pushViewController(vc, animated: true)
            case .termsAndConditions:
                let vc = WLMarkdownVC(title: L10n.termsOfUse.uppercaseFirst, bundledMarkdownTxtFileName: "Terms_of_service")
                present(vc, interactiveDismissalType: .standard, completion: nil)
            }
        }
    }
}