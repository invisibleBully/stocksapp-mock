//
//  Search.swift
//  StocksApp
//
//  Created by Jude Botchwey on 07/10/2021.
//

import Foundation


struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}




struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResult]
}
