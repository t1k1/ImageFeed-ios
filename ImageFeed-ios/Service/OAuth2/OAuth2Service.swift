//
//  OAuth2Service.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 02.08.2023.
//

import Foundation

final class OAuth2Service {
    //MARK: - Variables
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    //MARK: - Main function
    func fetchAuthToken(
        _ code: String,
        complition: @escaping (Result<String,Error>) -> Void
    ) {
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    complition(.success(authToken))
                case .failure(let error):
                    complition(.failure(error))
            }
        }
        task.resume()
    }
}

//MARK: - Private functions
private extension OAuth2Service {
    /// Запрос и обработка ответа от сервера
    func object(
        for request: URLRequest,
        complition: @escaping (Result<OAuthTokenResponseBody,Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        return urlSession.data(for: request ) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            complition(response)
        }
    }
    
    // Вспомогательная функция для получения своего профиля
    var selfProfileRequest: URLRequest {
        URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
    }
    
    /// Вспомогательная функция для получения картинки профиля
    func profileImageURLRequest(userName: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: "GET"
        )
    }
    
    /// Вспомогательная функция для получения картинок
    func photosRequest(page: Int, perPage: Int) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(page)"
            + "&&per_page=\(perPage)",
            httpMethod: "GET"
        )
    }
    
    /// Вспомогательная функция для получения лайкнутых картинок
    func likeRequest(photoId: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "POST"
        )
    }
    
    /// Вспомогательная функция для получения не лайкнутых картинок
    func unlikeRequest(photoId: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "DELETE"
        )
    }
    
    //    /// Вспомогательная функция для получения авторизационного токена
    //    func authTokenRequest(code: String) -> URLRequest {
    //        URLRequest.makeHTTPRequest(
    //            path: "/oauth/token"
    //            + "?client_id=\(AccessKey)"
    //            + "&&client_secret=\(SecretKey)"
    //            + "&&redirect_uri=\(RedirectURI)"
    //            + "&&code=\(code)"
    //            + "&&grant_type=authorization_code",
    //            httpMethod: "POST",
    //            host: "unsplash.com"
    //        )
    //    }
    
    /// Вспомогательная функция для получения авторизационного токена
    func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
    
}
