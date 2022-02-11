//
// Created by Giang Long Tran on 07.02.2022.
//

import Foundation
import RxSwift
import SolanaSwift

struct RentBTC {
    typealias Service = RentBTCServiceType
}

protocol RentBTCServiceType {
    /**
     Checks the associated account has been created
     - Returns: the status
     */
    func hasAssociatedTokenAccountBeenCreated() -> Single<Bool>
    
    /**
     Checks the associated account is creatable
     - Returns: true if account is creatable or false. The false happens when wallet balance is not enough for creating.
     */
    func isAssociatedAccountCreatable() -> Single<Bool>
    
    /**
     Creates a associated account
     - Parameters:
       - payingFeeAddress: the address that will pay a fee
       - payingFeeMintAddress: the mint address that will pay a fee
     - Returns:
     */
    func createAssociatedTokenAccount(payingFeeAddress: String, payingFeeMintAddress: String) -> Single<SolanaSDK.TransactionID>
}
