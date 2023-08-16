//
//  ProfileService.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 15.08.2023.
//

import Foundation

final class ProfileService {
    //MARK: - Variables
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var profile: Profile?
    private struct Keys {
        static let authorization = "Authorization"
        static let bearer = "Bearer"
        static let nilBio = "User has no description"
        static let httpMethodGet = "GET"
    }
    
    //MARK: - Initialization
    private init() { }
    
    //MARK: - Main function
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if profile != nil { return }
        task?.cancel()
        
        var requestProfile = selfProfileRequest
        requestProfile?.addValue("\(Keys.bearer) \(token)", forHTTPHeaderField: Keys.authorization)
        
        guard let requestProfile = requestProfile else {
            return
        }
        
        let task = object(for: requestProfile) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                    case .success(let body):
                        let profile = Profile(
                            username: body.username,
                            name: "\(body.firstName) \(body.lastName)",
                            bio: body.bio ?? Keys.nilBio
                        )
                        
                        self.profile = profile
                        
                        completion(.success(profile))
                        self.task = nil
                    case .failure(let error):
                        completion(.failure(error))
                        self.profile = nil
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}

//MARK: - Private functions
private extension ProfileService {
    /// Запрос и обработка ответа от сервера
    func object(
        for request: URLRequest,
        complition: @escaping (Result<ProfileResult,Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        return urlSession.data(for: request ) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result {
                    try decoder.decode(ProfileResult.self, from: data)
                }
            }
            complition(response)
        }
    }
    
    /// Вспомогательная функция для получения своего профиля
    var selfProfileRequest: URLRequest? {
        URLRequest.makeHTTPRequest(path: "/me", httpMethod: Keys.httpMethodGet)
    }
    
    /// Вспомогательная функция для получения картинки профиля
    func profileImageURLRequest(userName: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: Keys.httpMethodGet
        )
    }
}
