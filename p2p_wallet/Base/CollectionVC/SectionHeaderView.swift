//
//  SectionHeaderView.swift
//  p2p_wallet
//
//  Created by Chung Tran on 11/3/20.
//

import Foundation

class SectionHeaderView: UICollectionReusableView {
    lazy var stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .center, distribution: .fill)
    
    lazy var headerLabel = UILabel(text: "Wallets", textSize: 17, weight: .bold, numberOfLines: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(all: 16))
        
        stackView.addArrangedSubview(headerLabel)
        headerLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor)
            .isActive = true
    }
}
