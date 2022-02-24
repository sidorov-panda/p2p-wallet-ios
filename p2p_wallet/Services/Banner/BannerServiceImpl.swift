//
// Created by Giang Long Tran on 18.02.2022.
//

import Foundation
import RxCocoa
import RxSwift

class BannerServiceImpl: Banners.Service {
    private var _banners: Set<Banners.Banner> = []
    private var _handler: [WeakHandler] = []

    init(handlers: [Banners.Handler]) {
        for handler in handlers {
            register(handler: handler)
        }
    }

    private var bannersSubject = BehaviorRelay<Set<Banners.Banner>>(value: [])
    var banners: Driver<[Banners.Banner]> {
        bannersSubject
            .map { $0.sorted { a, b in a.priority.rawValue >= b.priority.rawValue } }
            .asDriver(onErrorJustReturn: [])
    }

    func register(handler: Banners.Handler) {
        handler.onRegister(with: self)
        _handler.append(WeakHandler(handler: handler))
        _handler = _handler.filter { $0.handler != nil }
    }

    func unregister(handler: Banners.Handler) {
        _handler = _handler.filter { $0.handler !== handler }
        _handler = _handler.filter { $0.handler != nil }
    }

    func update(banner: Banners.Banner) {
        print(banner)
        _banners.insert(banner)
        bannersSubject.accept(_banners)
    }

    func remove(bannerId: String) {
        _banners = _banners.filter { banner in banner.id != bannerId }
        bannersSubject.accept(_banners)
    }
}

extension BannerServiceImpl {
    private struct WeakHandler {
        weak var handler: Banners.Handler?
    }
}
