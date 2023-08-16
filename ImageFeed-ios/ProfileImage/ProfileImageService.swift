//
//  ProfileImageService.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 16.08.2023.
//

import Foundation

final class ProfileImageService {
    //MARK: - Variables
    private struct Keys {
        static let authorization = "Authorization"
        static let bearer = "Bearer"
        static let httpMethodGet = "GET"
        static let notificationName = "ProfileImageProviderDidChange"
        static let paramNameURL = "URL"
    }
    static let shared = ProfileImageService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    static let DidChangeNotification = Notification.Name(rawValue: Keys.notificationName)
    
    //MARK: - Initialization
    private init() { }
    
    //MARK: - Main function
    func fetchProfileImageURL(
        token: String,
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ){
        assert(Thread.isMainThread)
        if avatarURL != nil { return }
        task?.cancel()
        
        var requestImage = profileImageURLRequest(userName: username)
        requestImage?.addValue("\(Keys.bearer) \(token)", forHTTPHeaderField: Keys.authorization)
        
        guard let requestImage = requestImage else { return }
        
        let task = object(for: requestImage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                    case .success(let body):
                        let avatarURL = body.profileImage?.small
                        
                        guard let avatarURL = avatarURL else { return }
                        self.avatarURL = avatarURL
                        
                        completion(.success(avatarURL))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.DidChangeNotification,
                                object: self,
                                userInfo: [Keys.paramNameURL: avatarURL])
                        
                        self.task = nil
                    case .failure(let error):
                        completion(.failure(error))
                        self.avatarURL = nil
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}

//MARK: - Private functions
private extension ProfileImageService {
    /// Запрос и обработка ответа от сервера
    func object(
        for request: URLRequest,
        complition: @escaping (Result<UserResult,Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        return urlSession.data(for: request ) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<UserResult, Error> in
                Result {
                    try decoder.decode(UserResult.self, from: data)
                }
            }
            complition(response)
        }
    }
    
    /// Вспомогательная функция для получения картинки профиля
    func profileImageURLRequest(userName: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: Keys.httpMethodGet
        )
    }
}

