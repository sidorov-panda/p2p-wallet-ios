//
//  RenVMSolanaTransactionSender.swift
//  p2p_wallet
//
//  Created by Chung Tran on 12/02/2022.
//

import Foundation
import SolanaSwift
import FeeRelayerSwift
import RxSwift

class RenVMSolanaTransactionSender: RenVMSolanaTransactionSenderType {
    @Injected private var solanaSDK: SolanaSDK
    @Injected private var relayService: FeeRelayerRelayType
    @Injected private var feeRelayerAPIClient: FeeRelayerAPIClientType
    var payingFeeToken: FeeRelayer.Relay.TokenInfo?
    
    init() {
        payingFeeToken = .init(address: solanaSDK.accountStorage.account?.publicKey.base58EncodedString ?? "", mint: SolanaSDK.PublicKey.wrappedSOLMint.base58EncodedString)
    }
    
    func getFeePayer() -> Single<SolanaSDK.PublicKey> {
        feeRelayerAPIClient.getFeePayerPubkey().map {try SolanaSDK.PublicKey(string: $0)}
    }
    
    func serializeAndSend(preparedTransaction: SolanaSDK.PreparedTransaction, isSimulation: Bool) -> Single<String> {
        if payingFeeToken?.mint == SolanaSDK.PublicKey.wrappedSOLMint.base58EncodedString {
            return solanaSDK.serializeAndSend(preparedTransaction: preparedTransaction, isSimulation: isSimulation)
        }
        return relayService.topUpAndRelayTransaction(
            preparedTransaction: preparedTransaction,
            payingFeeToken: payingFeeToken
        ).map {$0.first ?? ""}
    }
}
