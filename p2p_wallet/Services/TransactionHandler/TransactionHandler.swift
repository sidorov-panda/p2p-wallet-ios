//
//  TransactionHandler.swift
//  p2p_wallet
//
//  Created by Chung Tran on 05/03/2022.
//

import Foundation
import RxCocoa
import RxSwift

protocol TransactionHandlerType {
    typealias TransactionIndex = Int
    func sendTransaction(_ processingTransaction: RawTransactionType) -> TransactionIndex
    func observeTransaction(transactionIndex: TransactionIndex) -> Observable<PendingTransaction?>
    func areSomeTransactionsInProgress() -> Bool

    func observeProcessingTransactions(forAccount account: String) -> Observable<[SolanaSDK.ParsedTransaction]>
    func getProccessingTransactions(of account: String) -> [SolanaSDK.ParsedTransaction]

    var onNewTransaction: Observable<(trx: PendingTransaction, index: Int)> { get }
}

class TransactionHandler: TransactionHandlerType {
    @Injected var notificationsService: NotificationsServiceType
    @Injected var analyticsManager: AnalyticsManager
    @Injected var apiClient: ProcessTransactionAPIClient
    @Injected var walletsRepository: WalletsRepository
    @Injected var pricesService: PricesServiceType
    @Injected var socket: SocketType

    let disposeBag = DisposeBag()
    let transactionsSubject = BehaviorRelay<[PendingTransaction]>(value: [])
    let onNewTransactionPublish = PublishRelay<(trx: PendingTransaction, index: Int)>()
    var onNewTransaction: Observable<(trx: PendingTransaction, index: Int)> { onNewTransactionPublish.asObservable() }

    func sendTransaction(
        _ processingTransaction: RawTransactionType
    ) -> TransactionIndex {
        // get index to return
        let txIndex = transactionsSubject.value.count

        // add to processing
        let trx = PendingTransaction(
            transactionId: nil,
            sentAt: Date(),
            rawTransaction: processingTransaction,
            status: .sending
        )

        var value = transactionsSubject.value
        value.append(trx)

        transactionsSubject.accept(value)
        onNewTransactionPublish.accept((trx, txIndex))

        // process
        sendAndObserve(index: txIndex, processingTransaction: processingTransaction)

        return txIndex
    }

    func observeTransaction(
        transactionIndex: TransactionIndex
    ) -> Observable<PendingTransaction?> {
        transactionsSubject.map { $0[safe: transactionIndex] }
    }

    func areSomeTransactionsInProgress() -> Bool {
        transactionsSubject.value.contains(where: \.status.isProcessing)
    }

    func observeProcessingTransactions(
        forAccount account: String
    ) -> Observable<[SolanaSDK.ParsedTransaction]> {
        transactionsSubject
            .map { [weak self] _ in self?.getProccessingTransactions(of: account) ?? [] }
            .asObservable()
    }

    func getProccessingTransactions(
        of account: String
    ) -> [SolanaSDK.ParsedTransaction] {
        transactionsSubject.value
            .filter { pt in
                switch pt.rawTransaction {
                case let transaction as ProcessTransaction.SendTransaction:
                    if transaction.sender.pubkey == account ||
                        transaction.receiver.address == account ||
                        transaction.authority == account
                    {
                        return true
                    }
                case let transaction as ProcessTransaction.SwapTransaction:
                    if transaction.sourceWallet.pubkey == account ||
                        transaction.destinationWallet.pubkey == account ||
                        transaction.authority == account
                    {
                        return true
                    }
                default:
                    break
                }
                return false
            }
            .compactMap { pt -> SolanaSDK.ParsedTransaction? in
                pt.parse(pricesService: pricesService, authority: walletsRepository.nativeWallet?.pubkey)
            }
    }
}
