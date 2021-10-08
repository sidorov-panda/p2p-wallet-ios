//
//  HomeCollectionView.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/03/2021.
//

import Foundation
import Action
import BECollectionView
import RxSwift

class HomeCollectionView: WalletsCollectionView {
    // MARK: - Constants
    @Injected private var keychainStorage: KeychainAccountStorage
    
    // MARK: - Sections
    private let friendSection: FriendsSection
    
    // MARK: - Actions
    var reserveNameAction: CocoaAction?
    
    // MARK: - Initializers
    init(walletsRepository: WalletsRepository) {
        self.friendSection = FriendsSection(index: 2, viewModel: FriendsViewModel())
        super.init(
            header: .init(
                viewType: HeaderView.self,
                heightDimension: .estimated(154.5)
            ),
            walletsRepository: walletsRepository,
            activeWalletsSection: ActiveWalletsSection(index: 0, viewModel: walletsRepository),
            hiddenWalletsSection: HiddenWalletsSection(index: 1, viewModel: walletsRepository),
            additionalSections: [/*friendSection*/]
        )
    }
    
    override func configureHeaderView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        let headerView = super.configureHeaderView(kind: kind, indexPath: indexPath) as? HeaderView
        headerView?.repository = walletsRepository
        headerView?.reserveNameAction = reserveNameAction
        return headerView
    }
    
    override func dataDidChangeObservable() -> Observable<Void> {
        Observable.merge(
            walletsRepository.dataDidChange,
            UserDefaults.standard.rx.observe(Bool.self, "forceCloseNameServiceBanner").skip(1).map {_ in ()}
        )
    }
    
    override func dataDidLoad() {
        super.dataDidLoad()
        let headerView = collectionView.visibleSupplementaryViews(ofKind: "GlobalHeaderIdentifier").first as? HeaderView
        let shouldShowBanner = keychainStorage.getName() == nil && !Defaults.forceCloseNameServiceBanner
        headerView?.setHideBanner(!shouldShowBanner)
    }
}
