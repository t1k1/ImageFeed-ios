//
//  ImageFeed_iosTests.swift
//  ImageFeed-iosTests
//
//  Created by Aleksey Kolesnikov on 28.08.2023.
//
@testable import ImageFeed_ios
import XCTest

final class ImagesListServiceTests: XCTestCase {
    
    func testFetchPhotos() throws {
        let service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }
                
        service.fetchPhotosNextPage()
        service.fetchPhotosNextPage()
        service.fetchPhotosNextPage()
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
    
}
