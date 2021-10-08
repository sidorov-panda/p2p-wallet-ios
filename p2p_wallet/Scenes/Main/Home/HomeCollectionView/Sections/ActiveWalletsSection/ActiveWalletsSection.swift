//
//  ActiveWalletsSection.swift
//  p2p_wallet
//
//  Created by Chung Tran on 25/03/2021.
//

import Foundation
import BECollectionView
import Action

extension HomeCollectionView {
    class ActiveWalletsSection: WalletsSection {
        init(index: Int, viewModel: WalletsRepository) {
            super.init(
                index: index,
                viewModel: viewModel,
                cellType: HomeWalletCell.self
            )
        }
    }
}
