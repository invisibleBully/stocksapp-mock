//
//  APIManager.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import Foundation



final class APIManager {
    
    private init() {}
    static let shared = APIManager()
    
    
    private struct Constant {
        static let API_KEY = ""
        static let SANDBOX_API_KEY = ""
        static let BASE_URL = ""
    }
    
    
    private enum Endpoint: String {
        case search
    }
    
    
    private enum APIError: Error {
        case invalidUrl
        case noNetwork
        case noDataReturned
    }
    
    
    
    private func url(forEndpoint endpoint: Endpoint, queryParams: [String:Any] = [:]) -> URL? {
        
        return nil
    }
    
    
    
    
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
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
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }catch {
                completion(.failure(error))
            }
        })
        
        task.resume()
    }
    
    
    
    
    
}
