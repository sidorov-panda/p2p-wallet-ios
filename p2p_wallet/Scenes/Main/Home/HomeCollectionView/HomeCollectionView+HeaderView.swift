//
//  HomeCollectionView+HeaderView.swift
//  p2p_wallet
//
//  Created by Chung Tran on 07/07/2021.
//

import Foundation
import RxSwift
import Action

extension HomeCollectionView {
    class HeaderView: BaseCollectionReusableView {
        lazy var balancesOverviewView = BalancesOverviewView()
        private lazy var bannerView: WLBannerView = {
            let bannerView = WLBannerView(
                title: L10n.reserveYourP2PUsernameNow,
                description: L10n.anyTokenCanBeReceivedUsingUsernameRegardlessOfWhetherItIsInYourWalletsList
            )
                .onTap(self, action: #selector(bannerDidTouch))
            bannerView.closeButtonCompletion = {
                Defaults.forceCloseNameServiceBanner = true
            }
            return bannerView
        }()
        var reserveNameAction: CocoaAction?
        
        private var disposable: Disposable?
        var repository: WalletsRepository? {
            didSet {
                guard let repository = repository else {return}
                disposable?.dispose()
                disposable = repository.stateObservable
                    .map {[weak self] in ($0, self?.repository?.getWallets() ?? [])}
                    .asDriver(onErrorJustReturn: (.loading, []))
                    .drive(onNext: {[weak self] (state, wallets) in
                        self?.balancesOverviewView.setUp(state: state, data: wallets)
                    })
            }
        }
        
        override func commonInit() {
            super.commonInit()
            // remove all arranged subviews
            stackView.arrangedSubviews.forEach {$0.removeFromSuperview()}
            
            // add header
            stackView.addArrangedSubviews {
                bannerView
                    .padding(.init(x: .defaultPadding, y: 0))
                BEStackViewSpacing(16)
                balancesOverviewView
                    .padding(.init(x: .defaultPadding, y: 0))
            }
            
            stackView.constraintToSuperviewWithAttribute(.top)?.constant = 20
            stackView.constraintToSuperviewWithAttribute(.bottom)?.constant = -30
        }
        
        func setHideBanner(_ isHidden: Bool) {
            bannerView.superview!.isHidden = isHidden
        }
        
        @objc func bannerDidTouch() {
            reserveNameAction?.execute()
        }
    }
}
