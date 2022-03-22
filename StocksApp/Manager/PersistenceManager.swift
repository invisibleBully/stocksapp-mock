//
//  PersistenceManager.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import Foundation



//["AAPL","MSFT","SNAP"]
//
final class PersistenceManager {
    
    
    static let shared = PersistenceManager()
    private let defaults: UserDefaults = .standard
    
    
    
    private struct Constant {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    
    
    public var watchList: [String] {
        if !hasOnboarded {
            defaults.set(true, forKey: Constant.onboardedKey)
            setupDefaults()
        }
        return defaults.stringArray(forKey: Constant.watchlistKey) ?? []
    }
    
    
    
    
    
    
    public func addToWatchList(){
        
    }
    
    
    
    
    public func removeFromWatchList(){
        
    }
    
    
    
    private var hasOnboarded: Bool {
        return defaults.bool(forKey: Constant.onboardedKey)
    }
    
    
    private func setupDefaults(){
        
        let map: [String:String] = [
            "AAPL":"Apple Inc.",
            "MSFT":"Microsoft Corporation",
            "SNAP":"Snap Inc.",
            "AMZN":"Amazon Inc.",
            "FB":"Meta",
            "PINS":"Pinterest"
        ]
        
        let symbols = map.keys.map{ $0 }
        defaults.set(symbols, forKey: Constant.watchlistKey)
        
        for (symbol, name) in map {
            defaults.set(name, forKey: symbol)
        }
    }
    
    
    
}
