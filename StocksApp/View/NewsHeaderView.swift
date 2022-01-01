//
//  NewsHeaderView.swift
//  StocksApp
//
//  Created by Jude Botchwey on 10/11/2021.
//

import UIKit

class NewsHeaderView: UITableViewHeaderFooterView {
    
    
    static let identifier = "NewsHeaderView"
    static let preferredHeight = 70
    
    
    struct ViewModel {
        let title: String
        let shouldShowActionButton: Bool
    }
    
    
    
    //MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
