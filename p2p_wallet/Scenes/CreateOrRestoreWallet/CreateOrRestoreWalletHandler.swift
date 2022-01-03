//
//  CreateOrRestoreWalletHandler.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/01/2022.
//

import Foundation

protocol CreateOrRestoreWalletHandler {
    func createWallet(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?)
    func restoreWallet(phrases: [String]?, derivablePath: SolanaSDK.DerivablePath?, name: String?)
    func cancelCreatingOrRestoringWallet()
}
