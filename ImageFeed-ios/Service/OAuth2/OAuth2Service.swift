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
    private var task: URLSessionTask?
    private var lastCode: String?
    private (set) var authToken: String? {
        get {
            let tokenStorage = OAuth2TokenStorage()
            return tokenStorage.token
        }
        set {
            let tokenStorage = OAuth2TokenStorage()
            tokenStorage.token = newValue
        }
    }
    
    //MARK: - Initialization
    private init() { }
    
    //MARK: - Main function
    func fetchAuthToken(
        _ code: String,
        completion: @escaping (Result<String,Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        guard let request = authTokenRequest(code: code) else {
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                    case .success(let body):
                        let authToken = body.accessToken
                        self.authToken = authToken
                        completion(.success(authToken))
                        self.task = nil
                    case .failure(let error):
                        completion(.failure(error))
                        self.lastCode = nil
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}

//MARK: - Functions for requests
private extension OAuth2Service {    
    func authTokenRequest(code: String) -> URLRequest? {
        let configuration = AuthConfiguration.standard
        return URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(configuration.accessKey)"
            + "&&client_secret=\(configuration.secretKey)"
            + "&&redirect_uri=\(configuration.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")
        )
    }
}
