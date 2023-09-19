//
//  ImageListPresenterSpy.swift
//  ImageFeed-iosTests
//
//  Created by Aleksey Kolesnikov on 18.09.2023.
//

import Foundation
import ImageFeed_ios

final class ImageListPresenterSpy: ImagesListViewPresenterProtocol {
    var view: ImageFeed_ios.ImagesListViewControllerProtocol?
    var configureImageListCalled: Bool = false
    
    func configureImageList() {
        configureImageListCalled = true
    }
    
    func updateTableView() {
        
    }
    
    func getLargeImageURL(from indexPath: IndexPath) -> URL? {
        return nil
    }
    
    func getPhotosCount() -> Int {
        return 0
    }
    
    func getPhoto(indexPath: IndexPath) -> ImageFeed_ios.Photo? {
        return nil
    }
    
    func fetchPhotosNextPage(indexPath: IndexPath) {
            
    }
    
    func changeLike(indexPath: IndexPath?, cell: ImageFeed_ios.ImagesListCell) {
        
    }
    
    func getCellHeight(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        return CGFloat()
    }
}
