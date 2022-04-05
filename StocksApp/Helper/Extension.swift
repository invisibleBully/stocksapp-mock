//
//  Extension.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import Foundation
import UIKit
import FloatingPanel





//MARK: - Notification
extension Notification.Name {

    static let didAddtoWatchList = Notification.Name("didAddtoWatchList")
    
    
}



//MARK: - Number Formatter

extension NumberFormatter {
    
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    
}


//MARK: - UIImageView

extension UIImageView {
    
    func setImage(withUrl url: URL?) {
        guard let url = url else {
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil  else {
                    return
                }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
        
    }
    
}



//MARK: - String

extension String {
    
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    
    static func percentage(fromDouble double: Double) -> String{
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    
    static func formatted(number: Double) -> String{
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
}



//MARK: - DateFormatter

extension DateFormatter {
    
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
}





//MARK: - Add Subviews

extension UIView {
    
    func addSubViews(_ views: UIView...){
        views.forEach({
            addSubview($0)
        })
    }
    
}


//MARK: - Framing

extension UIView {
    
    
    var width: CGFloat { frame.size.width }
    var height: CGFloat { frame.size.height }
    
    var left: CGFloat { frame.origin.x }
    var right: CGFloat { left + width }
    
    var top: CGFloat { frame.origin.y }
    var bottom: CGFloat { top + height}
    
    
}
