//
//  MovieDataManager.swift
//  OMDBAPP
//
//  Created by Equipp on 09/09/24.
//

import Foundation

class MovieDataManager {
    static let shared = MovieDataManager()
    private init() {}

    private let apiKey = "1a839120"
    
    private let baseURL = "https://www.omdbapi.com/"
    
    func fetchMovies(byName name: String, type: String?, page: Int = 1, completion: @escaping (Result<[Movie], Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "s", value: name),
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "page", value: String(page))
        ]
    
        if let movieType = type, movieType.lowercased() != "all" {
            urlComponents.queryItems?.append(URLQueryItem(name: "type", value: movieType))
        }
    
        guard let url = urlComponents.url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                
                if let movies = movieResponse.movies {
                    completion(.success(movies))
                } else {
                    completion(.failure(NSError(domain: "NoMovies", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func fetchMovieDetails(byTitle title: String, completion: @escaping (Result<Movie, Error>) -> Void) {
        let urlString = "\(baseURL)?t=\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                return
            }
            
            do {
                let movieDetail = try JSONDecoder().decode(Movie.self, from: data)
                completion(.success(movieDetail))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

}
