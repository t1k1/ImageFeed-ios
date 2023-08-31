//
//  ImagesListService.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 24.08.2023.
//

import Foundation

final class ImagesListService {
    //MARK: - Variables
    private let urlSession = URLSession.shared
    private let token = OAuth2TokenStorage().token
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private (set) var photos: [Photo] = []
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    //MARK: - Main functions
    func fetchPhotosNextPage() {
        let nextPage = getNumberOfNextPage()
        
        assert(Thread.isMainThread)
        if task != nil { return }
        guard let token = token else { return }
        
        var requestPhotos = photosRequest(page: nextPage, perPage: 10)
        requestPhotos?.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        guard let requestPhotos = requestPhotos else { return }
        
        let task = urlSession.objectTask(for: requestPhotos) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                    case .success(let body):
                        body.forEach { photo in
                            self.photos.append(Photo(
                                id: photo.id,
                                size: CGSize(width: photo.width,
                                             height: photo.height
                                            ),
                                createdAt: photo.createdAt?.dateTimeString,
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
                                userInfo: ["Photos": self.photos])
                        
                        self.task = nil
                    case .failure(let error):
                        print("!ОШИБКА загрузки картинок \(error)")
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
        if task != nil { return }
        
        var requestLike = isLike ? unlikeRequest(photoId: photoId) : likeRequest(photoId: photoId)
        guard let token = token else { return }
        requestLike?.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        guard let requestLike = requestLike else { return }
        
        let task = urlSession.objectTask(for: requestLike) { [weak self] (result: Result<LikeResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
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
                        
                        self.task = nil
                    case .failure(let error):
                        completion(.failure(error))
                        print("!ОШИБКА в запросе лайка \(error)")
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}

private extension ImagesListService {
    func getNumberOfNextPage() -> Int {
        guard let lastLoadedPage = lastLoadedPage else { return 1 }
        return lastLoadedPage + 1
    }
    
    /// Вспомогательная функция для получения картинок
    func photosRequest(page: Int, perPage: Int) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(page)"
            + "&&per_page=\(perPage)",
            httpMethod: "GET"
        )
    }
    
    /// Вспомогательная функция для получения лайкнутых картинок
    func likeRequest(photoId: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "POST"
        )
    }
    
    /// Вспомогательная функция для получения не лайкнутых картинок
    func unlikeRequest(photoId: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "DELETE"
        )
    }
}