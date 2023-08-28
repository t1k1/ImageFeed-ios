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
    
    //MARK: - Main function
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
}
