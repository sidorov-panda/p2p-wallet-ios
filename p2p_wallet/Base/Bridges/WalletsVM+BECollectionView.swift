//
//  WalletsVM+BECollectionView.swift
//  p2p_wallet
//
//  Created by Chung Tran on 25/03/2021.
//

import Foundation
import BECollectionView
import RxCocoa

protocol WalletsListViewModelType: BEListViewModelType {
    var state: BehaviorRelay<FetcherState<[Wallet]>> {get}
    var isHiddenWalletsShown: BehaviorRelay<Bool> {get}
    func hiddenWallets() -> [Wallet]
}

extension WalletsVM: WalletsListViewModelType {}
