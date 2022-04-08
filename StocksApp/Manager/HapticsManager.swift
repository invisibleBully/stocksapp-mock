//
//  HapticsManager.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import Foundation
import UIKit


/// Object to manage haptics
final class HapticsManager {
    
    
    ///singleton
    static let shared = HapticsManager()
    
    
    private init(){}
    
    
    ///vibrate lightly for a selection tap interaction
    public func vibrateForSelection(){
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    
    /// play haptics for given interaction
    /// - Parameter type: type to vibrate for
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    
    
}
