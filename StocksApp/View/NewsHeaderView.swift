//
//  NewsHeaderView.swift
//  StocksApp
//
//  Created by Jude Botchwey on 10/11/2021.
//

import UIKit


protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}


class NewsHeaderView: UITableViewHeaderFooterView {
    
    
    static let identifier = "NewsHeaderView"
    static let preferredHeight = 70.0
    
    weak var delegate: NewsHeaderViewDelegate?
    
    
    struct ViewModel {
        let title: String
        let shouldShowActionButton: Bool
    }
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    
    let button: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .systemBlue
        button.setTitle("+ Watchlist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    
    
    
    //MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubViews(label, button)
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: contentView.width - 28, height: contentView.height)
        
        button.sizeToFit()
        button.frame = CGRect(x: contentView.width - button.width - 16, y: (contentView.height - button.height) / 2, width: button.width + 10, height: button.height)
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
    }
    
    
    public func configure(withViewModel viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowActionButton
    }
    
    
    @objc private func didTapAddButton(){
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
    
    
    
}
