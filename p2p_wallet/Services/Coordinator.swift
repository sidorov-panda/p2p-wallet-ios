//
//  Coordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 04/01/2022.
//

import Foundation

protocol CoordinatorType: AnyObject {
    // MARK: - Properties
    var didFinish: ((CoordinatorType) -> Void)? { get set }

    // MARK: - Methods
    func start()
}
