//
//  SendService+Solana.swift
//  p2p_wallet
//
//  Created by Chung Tran on 12/02/2022.
//

import Foundation
import RxSwift
import SolanaSwift
import FeeRelayerSwift

extension SendService {
    // MARK: - Relay method
    func sendToSolanaBCViaRelayMethod(
        from wallet: Wallet,
        receiver: String,
        amount: SolanaSDK.Lamports,
        payingFeeWallet: Wallet?
    ) -> Single<String> {
        // get paying fee token
        let payingFeeToken = try? getPayingFeeToken(payingFeeWallet: payingFeeWallet)
        
        return prepareForSendingToSolanaNetworkViaRelayMethod(
            from: wallet,
            receiver: receiver,
            amount: amount.convertToBalance(decimals: wallet.token.decimals),
            payingFeeToken: payingFeeToken
        )
            .flatMap { [weak self] preparedTransaction in
                guard let self = self else { throw SolanaSDK.Error.unknown }
                
                if payingFeeToken?.mint == SolanaSDK.PublicKey.wrappedSOLMint.base58EncodedString {
                    // send normally, paid by SOL
                    return self.solanaSDK.serializeAndSend(
                        preparedTransaction: preparedTransaction,
                        isSimulation: false
                    )
                } else {
                    // use fee relayer
                    return self.relayService.topUpAndRelayTransaction(
                        preparedTransaction: preparedTransaction,
                        payingFeeToken: payingFeeToken
                    )
                        .map {$0.first ?? ""}
                }
            }
            .do(onSuccess: {
                Logger.log(message: "\($0)", event: .response)
            }, onError: {
                Logger.log(message: "\($0)", event: .error)
            })
    }
    
    func prepareForSendingToSolanaNetworkViaRelayMethod(
        from wallet: Wallet,
        receiver: String,
        amount: Double,
        payingFeeToken: FeeRelayer.Relay.TokenInfo?,
        recentBlockhash: String? = nil,
        lamportsPerSignature: SolanaSDK.Lamports? = nil,
        minRentExemption: SolanaSDK.Lamports? = nil,
        usingCachedFeePayerPubkey: Bool = false
    ) -> Single<SolanaSDK.PreparedTransaction> {
        let amount = amount.toLamport(decimals: wallet.token.decimals)
        guard let sender = wallet.pubkey else {return .error(SolanaSDK.Error.other("Source wallet is not valid"))}
        // form request
        if receiver == sender {
            return .error(SolanaSDK.Error.other(L10n.youCanNotSendTokensToYourself))
        }
        
        // prepare fee payer
        let feePayerRequest: Single<String?>
        let useFeeRelayer: Bool
        
        if payingFeeToken?.mint == SolanaSDK.PublicKey.wrappedSOLMint.base58EncodedString {
            feePayerRequest = .just(nil)
            useFeeRelayer = false
        } else {
            if usingCachedFeePayerPubkey, let pubkey = cachedFeePayerPubkey {
                feePayerRequest = .just(pubkey)
            } else {
                feePayerRequest = feeRelayerAPIClient.getFeePayerPubkey()
                    .map(Optional.init)
                    .do(onSuccess: {[weak self] in self?.cachedFeePayerPubkey = $0})
            }
            useFeeRelayer = true
        }
        
        return feePayerRequest
            .flatMap { [weak self] feePayer in
                guard let self = self else {return .error(SolanaSDK.Error.unknown)}
                let feePayer = feePayer == nil ? nil: try SolanaSDK.PublicKey(string: feePayer)
                
                if wallet.isNativeSOL {
                    return self.solanaSDK.prepareSendingNativeSOL(
                        to: receiver,
                        amount: amount,
                        feePayer: feePayer,
                        recentBlockhash: recentBlockhash,
                        lamportsPerSignature: lamportsPerSignature
                    )
                }
                
                // other tokens
                else {
                    return self.solanaSDK.prepareSendingSPLTokens(
                        mintAddress: wallet.mintAddress,
                        decimals: wallet.token.decimals,
                        from: sender,
                        to: receiver,
                        amount: amount,
                        feePayer: feePayer,
                        transferChecked: useFeeRelayer, // create transferChecked instruction when using fee relayer
                        recentBlockhash: recentBlockhash,
                        lamportsPerSignature: lamportsPerSignature,
                        minRentExemption: minRentExemption
                    ).map {$0.preparedTransaction}
                }
            }
    }
    
    // MARK: - Compensation method
    func sendToSolanaBCViaRewardMethod(
        from wallet: Wallet,
        receiver: String,
        amount: SolanaSDK.Lamports
    ) -> Single<String> {
        guard let owner = solanaSDK.accountStorage.account,
              let sender = wallet.pubkey
        else {return .error(SolanaSDK.Error.unauthorized)}
        return solanaSDK.getRecentBlockhash(commitment: nil)
            .flatMap {[weak self] recentBlockhash -> Single<((SolanaSDK.PreparedTransaction, String?), String)> in
                guard let self = self else { throw SolanaSDK.Error.unknown }
                return self.prepareForSendingToSolanaNetworkViaRewardMethod(
                    from: wallet,
                    receiver: receiver,
                    amount: amount.convertToBalance(decimals: wallet.token.decimals),
                    recentBlockhash: recentBlockhash
                )
                    .map {($0, recentBlockhash)}
            }
            .flatMap { [weak self] params, recentBlockhash in
                guard let self = self else { throw SolanaSDK.Error.unknown }
                // get signature
                guard let data = params.0.transaction.findSignature(pubkey: owner.publicKey)?.signature
                else { throw SolanaSDK.Error.other("Signature not found")}
                
                let authoritySignature = Base58.encode(data.bytes)
                
                let request: Single<String>
                if wallet.isNativeSOL {
                    request = self.feeRelayerAPIClient.sendTransaction(
                        .rewardTransferSOL(
                            .init(
                                sender: sender,
                                recipient: receiver,
                                amount: amount,
                                signature: authoritySignature,
                                blockhash: recentBlockhash
                            )
                        )
                    )
                } else {
                    request = self.feeRelayerAPIClient.sendTransaction(
                        .rewardTransferSPLToken(
                            .init(
                                sender: sender,
                                recipient: params.1!,
                                mintAddress: wallet.mintAddress,
                                authority: owner.publicKey.base58EncodedString,
                                amount: amount,
                                decimals: wallet.token.decimals,
                                signature: authoritySignature,
                                blockhash: recentBlockhash
                            )
                        )
                    )
                }
                
                return request
                    .do(onSuccess: {
                        Logger.log(message: "\($0)", event: .response)
                    }, onError: {
                        Logger.log(message: "\($0)", event: .error)
                    })
            }
    }
    
    private func prepareForSendingToSolanaNetworkViaRewardMethod(
        from wallet: Wallet,
        receiver: String,
        amount: Double,
        recentBlockhash: String? = nil,
        lamportsPerSignature: SolanaSDK.Lamports? = nil,
        minRentExemption: SolanaSDK.Lamports? = nil,
        usingCachedFeePayerPubkey: Bool = false
    ) -> Single<(SolanaSDK.PreparedTransaction, String?)> {
        let amount = amount.toLamport(decimals: wallet.token.decimals)
        guard let sender = wallet.pubkey else {return .error(SolanaSDK.Error.other("Source wallet is not valid"))}
        // form request
        if receiver == sender {
            return .error(SolanaSDK.Error.other(L10n.youCanNotSendTokensToYourself))
        }
        
        // prepare fee payer
        let feePayerRequest: Single<String?>
        if usingCachedFeePayerPubkey, let pubkey = cachedFeePayerPubkey {
            feePayerRequest = .just(pubkey)
        } else {
            feePayerRequest = feeRelayerAPIClient.getFeePayerPubkey()
                .map(Optional.init)
                .do(onSuccess: {[weak self] in self?.cachedFeePayerPubkey = $0})
        }
        
        return feePayerRequest
            .flatMap { [weak self] feePayer in
                guard let self = self else {return .error(SolanaSDK.Error.unknown)}
                let feePayer = feePayer == nil ? nil: try SolanaSDK.PublicKey(string: feePayer)
                
                if wallet.isNativeSOL {
                    return self.solanaSDK.prepareSendingNativeSOL(
                        to: receiver,
                        amount: amount,
                        feePayer: feePayer,
                        recentBlockhash: recentBlockhash,
                        lamportsPerSignature: lamportsPerSignature
                    ).map {($0, nil)}
                }
                
                // other tokens
                else {
                    return self.solanaSDK.prepareSendingSPLTokens(
                        mintAddress: wallet.mintAddress,
                        decimals: wallet.token.decimals,
                        from: sender,
                        to: receiver,
                        amount: amount,
                        feePayer: feePayer,
                        transferChecked: true, // create transferChecked instruction when using fee relayer
                        recentBlockhash: recentBlockhash,
                        lamportsPerSignature: lamportsPerSignature,
                        minRentExemption: minRentExemption
                    ).map {($0.preparedTransaction, $0.realDestination)}
                }
            }
    }
}
