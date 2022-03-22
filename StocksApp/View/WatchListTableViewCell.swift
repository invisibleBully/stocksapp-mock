//
//  WatchListTableViewCell.swift
//  StocksApp
//
//  Created by Nii Yemoh on 22/03/2022.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String //formatted
        let changeColor: UIColor //[red,green]
        let changePercentage: String
        //let chartViewModel: StockCHartView.ViewModel
        
    }
    
    
    static let identifier = "WatchListTableViewCell"
    static let preferredHeight: CGFloat = 60
    
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    private let miniChartView = StockChartView()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews(
            symbolLabel,
            priceLabel,
            companyNameLabel,
            miniChartView,
            changeLabel
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        companyNameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    
    public func configureCell(viewModel: ViewModel){
        symbolLabel.text = viewModel.symbol
        companyNameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
    }
    
}
