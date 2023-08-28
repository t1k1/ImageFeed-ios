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
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private (set) var photos: [Photo] = []
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    //MARK: - Main function
    
    //    если идёт закачка, то нового сетевого запроса не создаётся, а выполнение функции прерывается;
    //    при получении новых фотографий массив photos обновляется из главного потока, новые фото добавляются в конец массива;
    //    после обновления значения массива photos публикуется нотификация ImagesListService.DidChangeNotification.
    
    func fetchPhotosNextPage() {
        let nextPage = getNumberOfNextPage()
        
        assert(Thread.isMainThread)
        if task != nil { return }
        
        var requestPhotos = photosRequest(page: nextPage, perPage: 10)
        guard let requestPhotos = requestPhotos else { return }
        
        let task = urlSession.objectTask(for: requestPhotos) { [weak self] (result: Result<PhotosResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                    case .success(let body):
                        let photos = PhotosResult(photos: body.photos)
                        photos.photos.forEach { photo in
                            DispatchQueue.main.async {
                                self.photos.append(Photo(
                                    id: photo.id,
                                    size: CGSize(width: photo.width,
                                                 height: photo.height
                                                ),
                                    createdAt: photo.createdAt,
                                    welcomeDescription: photo.description,
                                    thumbImageURL: photo.urls.thumb,
                                    largeImageURL: photo.urls.full,
                                    isLiked: photo.likedByUser
                                )
                                )
                            }
                        }
                        
                        NotificationCenter.default
                            .post(
                                name: ImagesListService.DidChangeNotification,
                                object: self,
                                userInfo: ["Photos": self.photos])
                        
                        print("!УСПЕХ загрузки картинок")
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
