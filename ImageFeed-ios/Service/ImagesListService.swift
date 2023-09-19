//
//  ImagesListService.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 24.08.2023.
//

import Foundation

final class ImagesListService {
    //MARK: - Structure of string variables
    private struct Keys {
        static let nameNotification = "ImagesListServiceDidChange"
        static let bearer = "Bearer"
        static let authorization = "Authorization"
        static let photos = "Photos"
    }
    
    //MARK: - Variables
    private let urlSession = URLSession.shared
    private let token = OAuth2TokenStorage().token
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private (set) var photos: [Photo] = []
    static let DidChangeNotification = Notification.Name(rawValue: Keys.nameNotification)
    
    //MARK: - Functions for fetching data
    func fetchPhotosNextPage() {
        let nextPage = getNumberOfNextPage()
        
        assert(Thread.isMainThread)
        if task != nil { return }
        task?.cancel()
        
        guard let token = token else { return }
        
        var requestPhotos = photosRequest(page: nextPage, perPage: 10)
        requestPhotos?.addValue("\(Keys.bearer) \(token)", forHTTPHeaderField: Keys.authorization)
        
        guard let requestPhotos = requestPhotos else { return }
        
        let task = urlSession.objectTask(for: requestPhotos) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                
                switch result {
                    case .success(let body):
                        body.forEach { photo in
                            self.photos.append(
                                Photo(
                                    id: photo.id,
                                    size: CGSize(
                                        width: photo.width,
                                        height: photo.height
                                    ),
                                    createdAt: DateService.shared.dateFromString(str: photo.createdAt),
                                    welcomeDescription: photo.description,
                                    thumbImageURL: photo.urls.thumb,
                                    largeImageURL: photo.urls.full,
                                    isLiked: photo.likedByUser
                                )
                            )
                        }
                        self.lastLoadedPage = nextPage
                        NotificationCenter.default
                            .post(
                                name: ImagesListService.DidChangeNotification,
                                object: self,
                                userInfo: [Keys.photos: self.photos]
                            )
                        
                        
                    case .failure:
                        assertionFailure("Failed to load images")
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if likeTask != nil { return }
        likeTask?.cancel()
        
        var requestLike = isLike ? unlikeRequest(photoId: photoId) : likeRequest(photoId: photoId)
        guard let token = token else { return }
        requestLike?.addValue("\(Keys.bearer) \(token)", forHTTPHeaderField: Keys.authorization)
        
        guard let requestLike = requestLike else { return }
        
        let likeTask = urlSession.objectTask(for: requestLike) { [weak self] (result: Result<LikeResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.likeTask = nil
                
                switch result {
                    case .success(let body):
                        let likedByUser = body.photo.likedByUser
                        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                            let photo = self.photos[index]
                            let newPhoto = Photo(
                                id: photo.id,
                                size: photo.size,
                                createdAt: photo.createdAt,
                                welcomeDescription: photo.welcomeDescription,
                                thumbImageURL: photo.thumbImageURL,
                                largeImageURL: photo.largeImageURL,
                                isLiked: likedByUser
                            )
                            self.photos[index] = newPhoto
                        }
                        
                        completion(.success(likedByUser))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
        
        self.likeTask?.resume()
    }
}


//MARK: - Functions for requests
private extension ImagesListService {
    func getNumberOfNextPage() -> Int {
        guard let lastLoadedPage = lastLoadedPage else { return 1 }
        return lastLoadedPage + 1
    }
    
    func photosRequest(page: Int, perPage: Int) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(page)"
            + "&&per_page=\(perPage)",
            httpMethod: "GET"
        )
    }
    
    func likeRequest(photoId: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "POST"
        )
    }
    
    func unlikeRequest(photoId: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "DELETE"
        )
    }
}
