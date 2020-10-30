//
//  AppDelegate.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import UIKit
@_exported import BEPureLayout
@_exported import SolanaSwift
@_exported import SwiftyUserDefaults

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")!.load()
//        //for tvOS:
//        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/tvOSInjection.bundle")?.load()
//        //Or for macOS:
//        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
        #endif
        
        // BEPureLayoutConfiguration
        BEPureLayoutConfigs.defaultTextColor = .textBlack
        BEPureLayoutConfigs.defaultNavigationBarColor = .background
        BEPureLayoutConfigs.defaultNavigationBarTextFont = .systemFont(ofSize: 17, weight: .semibold)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let rootVC: UIViewController
        if KeychainStorage.shared.account == nil {
            rootVC = WelcomeVC()
        } else {
            if KeychainStorage.shared.pinCode == nil {
                let vc = PinCodeVC()
                vc.completion = {_ in
                    let vc = EnableBiometryVC()
                    let nc = BENavigationController(rootViewController: vc)
                    UIApplication.shared.keyWindow?.rootViewController = nc
                }
                rootVC = BENavigationController(rootViewController: vc)
            } else if !Defaults.didSetEnableBiometry {
                rootVC = BENavigationController(rootViewController: EnableBiometryVC())
            } else if !Defaults.didSetEnableNotifications {
                rootVC = BENavigationController(rootViewController: EnableNotificationsVC())
            } else {
                rootVC = BaseVC()
            }
        }
        
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        return true
    }

}
