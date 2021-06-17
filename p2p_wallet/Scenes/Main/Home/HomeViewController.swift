//
//  HomeViewController.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/03/2021.
//

import Foundation
import UIKit
import Action

protocol HomeScenesFactory {
    func makeWalletDetailViewController(pubkey: String, symbol: String) -> WalletDetail.ViewController
    func makeReceiveTokenViewController(tokenWalletPubkey: String?) -> ReceiveToken.ViewController?
    func makeSendTokenViewController(walletPubkey: String?, destinationAddress: String?) -> SendToken.ViewController
    func makeSwapTokenViewController(fromWallet wallet: Wallet?) -> SwapToken.ViewController
    func makeMyProductsViewController() -> MyProductsViewController
    func makeProfileVC() -> ProfileVC
    func makeTokenSettingsViewController(pubkey: String) -> TokenSettingsViewController
}

class HomeViewController: BaseVC {
    override var preferredNavigationBarStype: BEViewController.NavigationBarStyle {
        .hidden
    }
    
    // MARK: - Properties
    let viewModel: HomeViewModel
    let scenesFactory: HomeScenesFactory
    fileprivate let interactor = MenuInteractor()
    
    // MARK: - Tabbar
    lazy var homeRootView = HomeRootView(viewModel: viewModel)
    let analyticsManager: AnalyticsManagerType
    
    // MARK: - Initializer
    init(viewModel: HomeViewModel, scenesFactory: HomeScenesFactory, analyticsManager: AnalyticsManagerType)
    {
        self.viewModel = viewModel
        self.scenesFactory = scenesFactory
        self.analyticsManager = analyticsManager
        super.init()
    }
    
    // MARK: - Methods
    override func loadView() {
        self.view = homeRootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsManager.log(event: .walletsOpen)
    }
    
    override func setUp() {
        super.setUp()
        setStatusBarColor(view.backgroundColor!)
    }
    
    override func bind() {
        super.bind()
        
        viewModel.navigationSubject
            .subscribe(onNext: {[unowned self] in self.navigate(to: $0)})
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    private func navigate(to scene: HomeNavigatableScene) {
        switch scene {
        case .receiveToken:
            if let vc = self.scenesFactory.makeReceiveTokenViewController(tokenWalletPubkey: nil)
            {
                analyticsManager.log(event: .receiveOpen, params: ["fromPage": "wallets"])
                self.present(vc, animated: true, completion: nil)
            }
        case .scanQrWithSwiper(let progress, let state):
            MenuHelper.mapGestureStateToInteractor(
                gestureState: state,
                progress: progress,
                interactor: interactor)
            {
                let vc = QrCodeScannerVC()
                vc.callback = qrCodeScannerHandler(code:)
                vc.transitioningDelegate = self
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }
        case .scanQrCodeWithTap:
            let vc = QrCodeScannerVC()
            vc.callback = qrCodeScannerHandler(code:)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        case .sendToken(let address):
            let vc = self.scenesFactory
                .makeSendTokenViewController(walletPubkey: nil, destinationAddress: address)
            analyticsManager.log(event: .sendOpen, params: ["fromPage": "wallets"])
            self.present(vc, animated: true, completion: nil)
        case .swapToken:
            let vc = self.scenesFactory.makeSwapTokenViewController(fromWallet: nil)
            analyticsManager.log(event: .swapOpen, params: ["fromPage": "wallets"])
            self.present(vc, animated: true, completion: nil)
        case .allProducts:
            let vc = self.scenesFactory.makeMyProductsViewController()
            self.present(vc, animated: true, completion: nil)
        case .profile:
            analyticsManager.log(event: .settingsOpen, params: ["fromPage": "wallets"])
            let profileVC = self.scenesFactory.makeProfileVC()
            self.show(profileVC, sender: nil)
        case .walletDetail(let wallet):
            guard let pubkey = wallet.pubkey else {return}
            
            analyticsManager.log(event: .walletOpen, params: ["tokenTicker": wallet.token.symbol])
            
            let vc = scenesFactory.makeWalletDetailViewController(pubkey: pubkey, symbol: wallet.token.symbol)
            present(vc, animated: true, completion: nil)
        case .walletSettings(let wallet):
            guard let pubkey = wallet.pubkey else {return}
            let vc = self.scenesFactory.makeTokenSettingsViewController(pubkey: pubkey)
            self.present(vc, animated: true, completion: nil)
        case .addToken:
//            let vc = self.scenesFactory.makeAddNewTokenVC()
//            self.present(vc, animated: true, completion: nil)
            break
        }
    }
    
    private func qrCodeScannerHandler(code: String) -> Bool {
        if NSRegularExpression.publicKey.matches(code) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.viewModel.navigationSubject.onNext(.sendToken(address: code))
            }
            return true
        }
        return false
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PresentMenuAnimator()
    }
    
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        DismissMenuAnimator()
//    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
