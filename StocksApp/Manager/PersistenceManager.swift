//
//  PersistenceManager.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import Foundation



final class PersistenceManager {
    
    static let shared = PersistenceManager()
    private let userDefaults: UserDefaults = .standard
    
    
    
    
    private struct Constant {
        
    }
    
    
    
    var watchList: [String] {
        return []
    }
    
    
    
    public func addToWatchList(){
        
    }
    
    public func removeFromWatchList(){
        
    }
    
    
    
    private var hasOnboarded: Bool {
        return false
    }
    
    
    
}
