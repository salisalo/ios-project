//
//  NetworkManager.swift
//  TvShows
//
//  Created by Salo Antidze on 3/11/21.
//

import Foundation

final class NetworkManager {
    
    public static let shared = NetworkManager()
    //var page = 1
    var isPaginationInProgress = false
    
    let baseUrl = "https://api.themoviedb.org/3"
    let posterBaseUrl = "https://www.themoviedb.org/t/p/h100/"
    let largePosterBaseUrl = "https://www.themoviedb.org/t/p/w154/"
    let apiKey = "8002555909dabb1c508c84c78a06b400"
    
    
    
    func getTvShowsInfo(page: Int, completionHandler: @escaping (_ result: [TvShowInfo]?, _ error: String?) -> Void) {
        let urlString = baseUrl + "/tv/popular"
        let parameters = ["api_key" : apiKey, "page" : "\(page)"]
        
        getData(urlString: urlString, parameters: parameters) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    func getSimilarTvShows(tvShowsId: Int, completionHandler: @escaping (_ result: [TvShowInfo]?, _ error: String?) -> Void) {
    
        let urlString = baseUrl + "/tv/\(tvShowsId)/similar"
        let parameters = ["api_key" : apiKey, "page" : "1"]
        
        getData(urlString: urlString, parameters: parameters) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    func searchTvShows(searchPage: Int, tvShowKeyword: String, completionHandler: @escaping (_ result: [TvShowInfo]?, _ error: String?) -> Void) {
        let urlString = baseUrl + "/search/tv"
        let parameters = ["api_key" : apiKey, "page" : "\(searchPage)", "query": tvShowKeyword]
        
        getData(urlString: urlString, parameters: parameters) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    func createRequest(_ urlString: String, _ parameters: [String:String]) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: urlString) else { return nil }
        
        var queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: (urlComponents.url)!)
        request.httpMethod = "GET"
        
        return request
    }
    
    func getData(urlString: String, parameters: [String:String], completionHandler: @escaping (_ result: [TvShowInfo]?, _ error: String?) -> Void ) {
        
        guard let request = createRequest(urlString, parameters)
        else { return }
        
        isPaginationInProgress = true
                
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
            }
            if let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(TvShowInfoResponse.self, from: data)
                    completionHandler(apiResponse.results, nil)
                }
                catch {
                    print(error)
                }
            }
            self.isPaginationInProgress = false
        })
        task.resume()
    }
    
    
    func getGenres(completionHandler: @escaping (_ result: [Genres]?, _ error: String?) -> Void) {
        let urlString = baseUrl + "/genre/movie/list"
        let parameters = ["api_key" : apiKey]
        
        guard let request = createRequest(urlString, parameters)
        else { return }
                        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
            }
            
            if let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(GenresResponse.self, from: data)
                    completionHandler(apiResponse.genres, nil)
                }
                catch {
                    completionHandler(nil, error.localizedDescription)
                }
            }
        })
        task.resume()
    }
    
}

