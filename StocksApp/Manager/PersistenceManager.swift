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
    
    
    
    
    
    /// add symbol to watch list
    /// - Parameters:
    ///   - symbol: company symbol
    ///   - companyName: company name
    public func addToWatchList(symbol: String, companyName: String){
        var current = watchList
        current.append(symbol)
        defaults.set(current, forKey: Constant.watchlistKey)
        defaults.set(companyName, forKey: symbol)
        NotificationCenter.default.post(name: .didAddtoWatchList, object: nil)
    }
    
    
    
    /// check if watchlist contains symbol to be added
    /// - Parameter symbol: company symbol
    /// - Returns: boolean
    public func watchListContains(symbol: String) -> Bool {
        return watchList.contains(symbol)
    }
    
    
    
    /// remove company symbol from watchlist
    /// - Parameter symbol: company symbol
    public func removeFromWatchList(symbol: String){
        var newWatchList = [String]()
        defaults.set(nil, forKey: symbol)
        for item in watchList where item != symbol{
            newWatchList.append(item)
        }
        defaults.set(newWatchList, forKey: Constant.watchlistKey)
    }
    
    
    
    /// check if user has onboarded
    private var hasOnboarded: Bool {
        return defaults.bool(forKey: Constant.onboardedKey)
    }
    
    
    
    /// set up default watch list items
    private func setupDefaults(){
        
        let map: [String:String] = [
            "AAPL":"Apple Inc.",
            "MSFT":"Microsoft Corporation",
            "SNAP":"Snap Inc.",
            "AMZN":"Amazon Inc.",
            "FB":"Meta",
            "PINS":"Pinterest",
            "NVDA":"Nvidia"
        ]
        
        let symbols = map.keys.map{ $0 }
        defaults.set(symbols, forKey: Constant.watchlistKey)
        
        for (symbol, name) in map {
            defaults.set(name, forKey: symbol)
        }
    }
    
    
    
}
