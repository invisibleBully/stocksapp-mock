//
//  News.swift
//  StocksApp
//
//  Created by Nii Yemoh on 03/02/2022.
//

import Foundation


struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}





