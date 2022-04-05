//
//  WatchListTableViewCell.swift
//  StocksApp
//
//  Created by Nii Yemoh on 22/03/2022.
//

import UIKit



protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchListTableViewCell: UITableViewCell {
    
    
    weak var delegate: WatchListTableViewCellDelegate?
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String //formatted
        let changeColor: UIColor //[red,green]
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }
    
    
    static let identifier = "WatchListTableViewCell"
    static let preferredHeight: CGFloat = 60
    
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .heavy)
        return label
    }()
    
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.layer.masksToBounds = true
        label.textAlignment = .right
        label.textColor = .white
        label.layer.cornerRadius = 2.0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    
    
    private let miniChartView:  StockChartView = {
        let chartView = StockChartView()
        chartView.clipsToBounds = true
        return chartView
    }()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
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
        
        symbolLabel.sizeToFit()
        companyNameLabel.sizeToFit()
        changeLabel.sizeToFit()
        priceLabel.sizeToFit()
        
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - companyNameLabel.height) / 2
        
        symbolLabel.frame = CGRect(x: separatorInset.left,
                                   y: yStart,
                                   width: symbolLabel.width,
                                   height: symbolLabel.height)
        
        
        companyNameLabel.frame = CGRect(x: separatorInset.left,
                                        y: symbolLabel.bottom,
                                        width: companyNameLabel.width,
                                        height: companyNameLabel.height)
        
        
        
        let currentWidth = max(max(priceLabel.width, changeLabel.width),
                               WatchListViewController.maxChangeWidth)
        
        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }
        
        priceLabel.frame = CGRect(x: contentView.width - 10 - currentWidth,
                                  y: (contentView.height - priceLabel.height - changeLabel.height) / 2,
                                  width: currentWidth,
                                  height: priceLabel.height)
        
        
        
        changeLabel.frame = CGRect(x: contentView.width - 10 - currentWidth,
                                   y: priceLabel.bottom,
                                   width: currentWidth,
                                   height: changeLabel.height)
        
        
        miniChartView.frame = CGRect(x: priceLabel.left - (contentView.width/3) - 5,
                                     y: 6,
                                     width: contentView.width / 3,
                                     height: contentView.height - 12)
        
        
        
        
        
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
        //configure chart
    }
    
}
