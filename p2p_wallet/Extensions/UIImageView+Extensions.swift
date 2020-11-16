//
//  UIImageView+Extensions.swift
//  p2p_wallet
//
//  Created by Chung Tran on 13/11/2020.
//

import Foundation
import SDWebImage

extension UIImageView {
    func setImage(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            image = UIColor.gray.image(frame.size)
            return
        }
        sd_setImage(with: url) { [weak self] (image, _, _, _) in
            if image == nil {
                self?.image = UIColor.gray.image(self?.frame.size ?? .zero)
            }
        }
    }
}
