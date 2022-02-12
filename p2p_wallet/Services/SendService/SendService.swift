//
//  SendServiceType.swift
//  p2p_wallet
//
//  Created by Chung Tran on 27/09/2021.
//

import Foundation
import RxSwift
import FeeRelayerSwift
import OrcaSwapSwift

protocol SendServiceType {
    var relayMethod: SendTokenRelayMethod { get }
    
    func load() -> Completable
    func checkAccountValidation(account: String) -> Single<Bool>
    func isTestNet() -> Bool
    
    func getFees(
        from wallet: Wallet,
        receiver: String?,
        network: SendToken.Network,
        payingFeeToken: FeeRelayer.Relay.TokenInfo?
    ) -> Single<SolanaSDK.FeeAmount?>
    func getFeesInPayingToken(
        feeInSOL: SolanaSDK.Lamports,
        payingFeeWallet: Wallet
    ) -> Single<SolanaSDK.Lamports?>
    
    func send(
        from wallet: Wallet,
        receiver: String,
        amount: Double,
        network: SendToken.Network,
        payingFeeWallet: Wallet?
    ) -> Single<String>
}

class SendService: SendServiceType {
    let relayMethod: SendTokenRelayMethod
    @Injected var solanaSDK: SolanaSDK
    @Injected private var orcaSwap: OrcaSwapType
    @Injected var feeRelayerAPIClient: FeeRelayerAPIClientType
    @Injected var relayService: FeeRelayerRelayType
    @Injected private var renVMBurnAndReleaseService: RenVMBurnAndReleaseServiceType
    @Injected private var feeService: FeeServiceType
    var cachedFeePayerPubkey: String?
    
    init(relayMethod: SendTokenRelayMethod) {
        self.relayMethod = relayMethod
    }
    
    // MARK: - Methods
    func load() -> Completable {
        var completables = [feeService.load()]
        
        if relayMethod == .relay {
            completables.append(orcaSwap.load().andThen(relayService.load()))
        }
        
        return .zip(completables)
    }
    
    func checkAccountValidation(account: String) -> Single<Bool> {
        solanaSDK.checkAccountValidation(account: account)
    }
    
    func isTestNet() -> Bool {
        solanaSDK.endpoint.network.isTestnet
    }
    
    // MARK: - Fees calculator
    func getFees(
        from wallet: Wallet,
        receiver: String?,
        network: SendToken.Network,
        payingFeeToken: FeeRelayer.Relay.TokenInfo?
    ) -> Single<SolanaSDK.FeeAmount?> {
        guard let receiver = receiver else {
            return .just(nil)
        }

        switch network {
        case .bitcoin:
            return .just(
                .init(
                    transaction: 20000,
                    accountBalances: 0,
                    others: [
                        .init(amount: 0.0002, unit: "renBTC")
                    ]
                )
            )
        case .solana:
            switch relayMethod {
            case .relay:
                return prepareForSendingToSolanaNetworkViaRelayMethod(
                    from: wallet,
                    receiver: receiver,
                    amount: 10000, // placeholder
                    payingFeeToken: payingFeeToken,
                    recentBlockhash: "FR1GgH83nmcEdoNXyztnpUL2G13KkUv6iwJPwVfnqEgW", // placeholder
                    lamportsPerSignature: feeService.lamportsPerSignature, // cached lamportsPerSignature
                    minRentExemption: feeService.minimumBalanceForRenExemption,
                    usingCachedFeePayerPubkey: true
                )
                    .map { [weak self] preparedTransaction in
                        guard let self = self else {throw SolanaSDK.Error.unknown}
                        return self.relayService.calculateFee(preparedTransaction: preparedTransaction)
                    }
            case .reward:
                return .just(.zero)
            }
        }
    }
    
    func getFeesInPayingToken(
        feeInSOL: SolanaSDK.Lamports,
        payingFeeWallet: Wallet
    ) -> Single<SolanaSDK.Lamports?> {
        guard relayMethod == .relay else {return .just(nil)}
        guard let payingFeeWalletAddress = payingFeeWallet.pubkey else {return .just(nil)}
        if payingFeeWallet.isNativeSOL {return .just(feeInSOL)}
        return relayService.calculateFeeInPayingToken(
            feeInSOL: feeInSOL,
            payingFeeToken: .init(address: payingFeeWalletAddress, mint: payingFeeWallet.mintAddress)
        )
    }
    
    // MARK: - Send method
    func send(
        from wallet: Wallet,
        receiver: String,
        amount: Double,
        network: SendToken.Network,
        payingFeeWallet: Wallet? // nil for relayMethod == .reward
    ) -> Single<String> {
        let amount = amount.toLamport(decimals: wallet.token.decimals)
        guard let sender = wallet.pubkey else {return .error(SolanaSDK.Error.other("Source wallet is not valid"))}
        // form request
        if receiver == sender {
            return .error(SolanaSDK.Error.other(L10n.youCanNotSendTokensToYourself))
        }
        
        // detect network
        let request: Single<String>
        switch network {
        case .solana:
            switch relayMethod {
            case .relay:
                request = sendToSolanaBCViaRelayMethod(
                    from: wallet,
                    receiver: receiver,
                    amount: amount,
                    payingFeeWallet: payingFeeWallet
                )
            case .reward:
                request = sendToSolanaBCViaRewardMethod(
                    from: wallet,
                    receiver: receiver,
                    amount: amount
                )
            }
        case .bitcoin:
            switch relayMethod {
            case .relay:
                renVMBurnAndReleaseService.sender.payingFeeToken = try? getPayingFeeToken(payingFeeWallet: payingFeeWallet)
            case .reward:
                renVMBurnAndReleaseService.sender.payingFeeToken = .init(address: "", mint: SolanaSDK.PublicKey.wrappedSOLMint.base58EncodedString)
            }
            
            request = renVMBurnAndReleaseService.burn(
                recipient: receiver,
                amount: amount
            )
        }
        return request
    }
    
    func getPayingFeeToken(payingFeeWallet: Wallet?) throws -> FeeRelayer.Relay.TokenInfo? {
        if let payingFeeWallet = payingFeeWallet {
            guard let address = payingFeeWallet.pubkey else {
                throw SolanaSDK.Error.other("Paying fee wallet is not valid")
            }
            return .init(address: address, mint: payingFeeWallet.mintAddress)
        }
        return nil
    }
}
