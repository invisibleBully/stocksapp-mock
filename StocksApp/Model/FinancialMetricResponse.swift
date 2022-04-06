//
//  FinancialMetricResponse.swift
//  StocksApp
//
//  Created by Nii Yemoh on 05/04/2022.
//

import Foundation



struct FinancialMetricResponse: Codable {
    let metric: Metric
}



struct Metric: Codable {
    
    let tenDayAverageTradingVolume: Float
    let annualWeekHigh: Double
    let annualWeekLow: Double
    let annualWeekLowDate: String
    let annualWeekPriceReturnDaily: Float
    let beta: Float
    
    enum CodingKeys: String, CodingKey {
        
        case tenDayAverageTradingVolume = "10DayAverageTradingVolume"
        case annualWeekHigh = "52WeekHigh"
        case annualWeekLow = "52WeekLow"
        case annualWeekLowDate = "52WeekLowDate"
        case annualWeekPriceReturnDaily = "52WeekPriceReturnDaily"
        case beta = "beta"
        
    }
    
}


