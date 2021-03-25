//
//  ActiveWalletsSection.swift
//  p2p_wallet
//
//  Created by Chung Tran on 25/03/2021.
//

import Foundation
import BECollectionView

class ActiveWalletsSection: BECollectionViewSection {
    init(index: Int, viewModel: BEListViewModelType) {
        super.init(
            index: index,
            layout: .init(
                header: .init(
                    identifier: "ActiveWalletsSectionHeaderView",
                    viewClass: HeaderView.self
                ),
                cellType: HomeWalletCell.self,
                interGroupSpacing: 30,
                itemHeight: .absolute(45),
                horizontalInterItemSpacing: .fixed(16),
                background: BackgroundView.self
            ),
            viewModel: viewModel
        )
    }
}
