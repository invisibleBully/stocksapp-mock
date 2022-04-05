//
//  StockChartView.swift
//  StocksApp
//
//  Created by Nii Yemoh on 22/03/2022.
//

import UIKit

class StockChartView: UIView {
    
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func reset(){
        
    }
    
    
    func configure(withViewModel viewModel: ViewModel){
        
    }
    
}
