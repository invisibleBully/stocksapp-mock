//
//  APIManager.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import Foundation


/// Object to manage API calls
final class APIManager {
    
    
    /// Singleton
    public static let shared = APIManager()
    
    /// private constructor
    private init() {}
    
    
    /// Constants
    private struct Constant {
        static let API_KEY = "c5eso1iad3ib660qogng"
        static let SANDBOX_API_KEY = "sandbox_c5eso1iad3ib660qogo0"
        static let BASE_URL = "https://finnhub.io/api/v1/"
    }
    
    
    /// APIs endpoints
    private enum Endpoint: String {
        case search
        case topNews = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financialMetrics = "stock/metric"
    }
    
    
    private enum APIError: Error {
        case invalidUrl
        case noNetwork
        case noDataReturned
    }
    
    
    
    private func url(forEndpoint endpoint: Endpoint, queryParams: [String:Any] = [:]) -> URL? {
        
        var urlString = Constant.BASE_URL + endpoint.rawValue
        var queryItems =  [URLQueryItem]()
        
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: "\(value)"))
        }
        queryItems.append(.init(name: "token", value: Constant.API_KEY))
        let queryString  = queryItems.map {"\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        urlString += "?" + queryString
        
        
        return URL(string: urlString)
    }
    
    
    
    
    
    
    private func request<T: Codable>(url: URL?, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = url else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            
            
            
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }else{
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(type, from: data)
                completion(.success(result))
            }catch {
                completion(.failure(error))
            }
        })
        
        task.resume()
    }
    
    
    /// get market data for company
    /// - Parameters:
    ///   - symbol: given company stock symbol
    ///   - numberOfDays: number of days back from today
    ///   - completion: callback for result
    public func marketData(forSymbol symbol: String,
                           numberOfDays: TimeInterval = 7,
                           completion: @escaping (Result<MarketDataResponse, Error>) -> Void) {
        
        let today = Date().addingTimeInterval(-(60 * 60 * 24 * 2))
        let prior = today.addingTimeInterval(-(60 * 60 * 24 * 2 * numberOfDays))
        let url = url(forEndpoint: .marketData,
                      queryParams: ["symbol":symbol,
                                    "resolution":"1",
                                    "from":"\(Int(prior.timeIntervalSince1970))",
                                    "to":"\(Int(today.timeIntervalSince1970))"
                                   ]
        )
        
        request(url: url, type: MarketDataResponse.self, completion: completion)
        
        
    }
    
    
    
    
    
    /// search for company
    /// - Parameters:
    ///   - query: query string (symbol or name)
    ///   - completion: callback for result
    public func search(query: String, completion: @escaping (Result<SearchResponse,Error>) -> Void){
        
        guard let url = url(forEndpoint: .search, queryParams: ["q":query]) else {
            return
        }
        request(url: url, type: SearchResponse.self, completion: completion)
    }
    
    
    
    
    /// get news for type
    /// - Parameters:
    ///   - type: type of news (top stories, company news)
    ///   - completion: callback for result
    public func news(for type: StoryType, completion: @escaping (Result<[NewsStory],Error>) -> Void) {
        
        switch type {
            
        case .topStories:
            request(url: url(forEndpoint: .topNews, queryParams: ["category":"general"]), type: [NewsStory].self, completion: completion)
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(60 * 60 * 24 * 2))
            request(url: url(forEndpoint: .companyNews,
                             queryParams: ["symbol" : symbol,
                                           "from":DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                           "to":DateFormatter.newsDateFormatter.string(from: today)
                                          ]
                            ),
                    type: [NewsStory].self,
                    completion: completion)
        }
        
        
    }
    
    
    
    /// get metrics data for company
    /// - Parameters:
    ///   - symbol: company symbol
    ///   - completion: callback for result
    public func financialMetrics(forSymbol symbol: String,
                                 completion: @escaping (Result<FinancialMetricResponse,Error>) -> Void) {
        
        let url = url(forEndpoint: .financialMetrics, queryParams: [
            "symbol":"AAPL",
            "metric":"all"
        ]
        )
        
        request(url: url, type: FinancialMetricResponse.self, completion: completion)
    }
    
    
    
    
}
