//
//  APIManager.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import Foundation



final class APIManager {
    
    
    static let shared = APIManager()
    private init() {}
    
    
    
    private struct Constant {
        static let API_KEY = "c5eso1iad3ib660qogng"
        static let SANDBOX_API_KEY = "sandbox_c5eso1iad3ib660qogo0"
        static let BASE_URL = "https://finnhub.io/api/v1/"
    }
    
    
    private enum Endpoint: String {
        case search
        case topNews = "news"
        case companyNews = "company-news"
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
    
    
    
    
    
    public func search(query: String, completion: @escaping (Result<SearchResponse,Error>) -> Void){
        
        guard let url = url(forEndpoint: .search, queryParams: ["q":query]) else {
            return
        }
        request(url: url, type: SearchResponse.self, completion: completion)
    }
    
    
    
    
    public func news(for type: StoryType, completion: @escaping (Result<[NewsStory],Error>) -> Void) {
        
        //guard let url = url(forEndpoint: .topNews, queryParams: ["category":"general"]) else {
        //return
        //}
        
        switch type {
            
        case .topStories:
            request(url: url(forEndpoint: .topNews, queryParams: ["category":"general"]), type: [NewsStory].self, completion: completion)
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(60 * 60 * 24 * 2))
            request(url: url(forEndpoint: .companyNews, queryParams: ["symbol" : symbol,
                                                                      "from":DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                                                      "to":DateFormatter.newsDateFormatter.string(from: today)
                                                                     ]
                            ), type: [NewsStory].self, completion: completion)
        }
        
        
    }
    
    
    
    
}
