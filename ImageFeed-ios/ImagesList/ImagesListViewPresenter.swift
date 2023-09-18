//
//  ImagesListViewPresenter.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 13.09.2023.
//

import Foundation
import UIKit

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func configureImageList()
    func updateTableView()
    func getLargeImageURL(from indexPath: IndexPath) -> URL?
    func getPhotosCount() -> Int
    func getPhoto(indexPath: IndexPath) -> Photo?
    func fetchPhotosNextPage(indexPath: IndexPath)
    func changeLike(indexPath: IndexPath?, cell: ImagesListCell)
    func getCellHeight(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    private var imagesListService: ImagesListService?
    private var photos: [Photo] = []
    
    func configureImageList() {
        imagesListService = ImagesListService()
        guard let imagesListService = imagesListService else { return }
        imagesListService.fetchPhotosNextPage()
        
        view?.configureImageList()
    }
    
    func updateTableView() {
        guard let imagesListService = imagesListService else { return }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        self.photos = imagesListService.photos
        
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func getLargeImageURL(from indexPath: IndexPath) -> URL? {
        return URL(string: photos[indexPath.row].largeImageURL)
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func getPhoto(indexPath: IndexPath) -> Photo? {
        return photos[indexPath.row]
    }
    
    func fetchPhotosNextPage(indexPath: IndexPath) {
        guard let imagesListService = imagesListService else { return }
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func changeLike(indexPath: IndexPath?, cell: ImagesListCell) {
        guard let imagesListService = imagesListService,
              let indexPath = indexPath else {
            return
        }
        
        UIBlockingProgressHUD.show()
        
        let photo = photos[indexPath.row]
        let isLiked = photo.isLiked
        
        imagesListService.changeLike(
            photoId: photo.id,
            isLike: isLiked
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let isLiked):
                    self.photos[indexPath.row].isLiked = isLiked
                    cell.setIsLiked(isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    view?.showError()
            }
        }
    }
    
    func getCellHeight(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let image = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
