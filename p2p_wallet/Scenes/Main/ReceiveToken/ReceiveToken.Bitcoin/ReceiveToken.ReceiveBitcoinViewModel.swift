//
//  ReceiveToken.ReceiveBitcoinViewModel.swift
//  p2p_wallet
//
//  Created by Chung Tran on 15/09/2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol ReceiveTokenBitcoinViewModelType {
    var isReceivingRenBTCDriver: Driver<Bool> {get}
    var isLoadingDriver: Driver<Bool> {get}
    var errorDriver: Driver<String?> {get}
    var conditionAcceptedDriver: Driver<Bool> {get}
    var addressDriver: Driver<String?> {get}
    var timerSignal: Signal<Void> {get}
    
    func reload()
    func getSessionEndDate() -> Date?
    func acceptConditionAndLoadAddress()
    func toggleIsReceivingRenBTC(isReceivingRenBTC: Bool)
    func copyToClipboard(address: String, logEvent: AnalyticsEvent)
    func share()
    func showBTCAddressInExplorer()
}

extension ReceiveToken {
    class ReceiveBitcoinViewModel {
        // MARK: - Constants
        private let mintTokenSymbol = "BTC"
        private let version = "1"
        private let disposeBag = DisposeBag()
        private var loadingDisposable: Disposable?
        
        // MARK: - Properties
        private let rpcClient: RenVMRpcClientType
        private let solanaClient: RenVMSolanaAPIClientType
        private let destinationAddress: SolanaSDK.PublicKey
        private let sessionStorage: RenVMSessionStorageType
        private let analyticsManager: AnalyticsManagerType
        private let navigationSubject: BehaviorRelay<NavigatableScene?>
        
        private var lockAndMint: RenVM.LockAndMint?
        
        // MARK: - Subjects
        private let isReceivingRenBTCSubject = BehaviorRelay<Bool>(value: false)
        private let isLoadingSubject = BehaviorRelay<Bool>(value: false)
        private let errorSubject = BehaviorRelay<String?>(value: nil)
        private let conditionAcceptedSubject = BehaviorRelay<Bool>(value: false)
        private let addressSubject = BehaviorRelay<String?>(value: nil)
        private let timerSubject = PublishRelay<Void>()
        
        // MARK: - Initializers
        init(
            rpcClient: RenVMRpcClientType,
            solanaClient: RenVMSolanaAPIClientType,
            destinationAddress: SolanaSDK.PublicKey,
            sessionStorage: RenVMSessionStorageType,
            analyticsManager: AnalyticsManagerType,
            navigationSubject: BehaviorRelay<NavigatableScene?>
        ) {
            self.rpcClient = rpcClient
            self.solanaClient = solanaClient
            self.destinationAddress = destinationAddress
            self.sessionStorage = sessionStorage
            self.analyticsManager = analyticsManager
            self.navigationSubject = navigationSubject
            
            bind()
        }
        
        private func bind() {
            Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .map {_ in ()}
                .bind(to: timerSubject)
                .disposed(by: disposeBag)
            
            timerSubject
                .subscribe(onNext: { [weak self] in
                    guard let endAt = self?.getSessionEndDate() else {return}
                    if Date() >= endAt {
                        self?.expireCurrentSession()
                    }
                })
                .disposed(by: disposeBag)
        }
        
        func reload() {
            // clear old values
            isLoadingSubject.accept(false)
            errorSubject.accept(nil)
            conditionAcceptedSubject.accept(false)
            addressSubject.accept(nil)
            
            // if session exists, condition accepted, load session
            if sessionStorage.loadSession() != nil {
                acceptConditionAndLoadAddress()
            }
        }
        
        func acceptConditionAndLoadAddress() {
            conditionAcceptedSubject.accept(true)
            loadSession(savedSession: sessionStorage.loadSession())
        }
        
        private func loadSession(savedSession: RenVM.Session?) {
            // set loading
            isLoadingSubject.accept(true)
            
            loadingDisposable?.dispose()
            
            // request
            loadingDisposable = RenVM.SolanaChain.load(
                client: rpcClient,
                solanaClient: solanaClient
            )
                .observe(on: MainScheduler.instance)
                .flatMap {[weak self] solanaChain -> Single<Data> in
                    guard let self = self else {throw RenVM.Error.unknown}
                    
                    // create lock and mint
                    self.lockAndMint = try .init(
                        rpcClient: self.rpcClient,
                        chain: solanaChain,
                        mintTokenSymbol: self.mintTokenSymbol,
                        version: self.version,
                        destinationAddress: self.destinationAddress.data,
                        session: savedSession
                    )
                    
                    // save session
                    if savedSession == nil {
                        self.sessionStorage.saveSession(self.lockAndMint!.session)
                    }
                    
                    // generate address
                    return self.lockAndMint!.generateGatewayAddress()
                }
                .map {Base58.encode($0.bytes)}
                .subscribe(on: MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] address in
                    self?.isLoadingSubject.accept(false)
                    self?.addressSubject.accept(address)
                }, onFailure: {[weak self] error in
                    self?.isLoadingSubject.accept(false)
                    self?.errorSubject.accept(error.readableDescription)
                })
        }
        
        private func expireCurrentSession() {
            sessionStorage.expireCurrentSession()
            reload()
        }
        
        func toggleIsReceivingRenBTC(isReceivingRenBTC: Bool) {
            isReceivingRenBTCSubject.accept(isReceivingRenBTC)
        }
    }
}

extension ReceiveToken.ReceiveBitcoinViewModel: ReceiveTokenBitcoinViewModelType {
    var isReceivingRenBTCDriver: Driver<Bool> {
        isReceivingRenBTCSubject.asDriver()
    }
    
    var isLoadingDriver: Driver<Bool> {
        isLoadingSubject.asDriver()
    }
    
    var errorDriver: Driver<String?> {
        errorSubject.asDriver()
    }
    
    var conditionAcceptedDriver: Driver<Bool> {
        conditionAcceptedSubject.asDriver()
    }
    
    var addressDriver: Driver<String?> {
        addressSubject.asDriver()
    }
    
    var timerSignal: Signal<Void> {
        timerSubject.asSignal()
    }
    
    func getSessionEndDate() -> Date? {
        sessionStorage.loadSession()?.endAt
    }
    
    func copyToClipboard(address: String, logEvent: AnalyticsEvent) {
        UIApplication.shared.copyToClipboard(address, alert: false)
        analyticsManager.log(event: logEvent)
    }
    
    func share() {
        analyticsManager.log(event: .receiveAddressShare)
        navigationSubject.accept(.share(address: addressSubject.value ?? ""))
    }
    
    func showBTCAddressInExplorer() {
        guard let pubkey = addressSubject.value else {return}
        analyticsManager.log(event: .receiveViewExplorerOpen)
        navigationSubject.accept(.showBTCExplorer(address: pubkey))
    }
}
