//
//  ImageListTests.swift
//  ImageFeed-iosTests
//
//  Created by Aleksey Kolesnikov on 12.09.2023.
//

@testable import ImageFeed_ios
import XCTest

final class ImageListTests: XCTestCase {
    func testImageListCallsViewDidLoad() {
        let imageListViewController = ImagesListViewController()
        let imageListViewPresenter = ImageListPresenterSpy()
        imageListViewController.configure(imageListViewPresenter)
        
        _ = imageListViewController.view
        
        XCTAssertTrue(imageListViewPresenter.configureImageListCalled)
    }
}
