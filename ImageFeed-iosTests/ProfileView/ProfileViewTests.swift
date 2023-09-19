//
//  ProfileViewTests.swift
//  ImageFeed-iosTests
//
//  Created by Aleksey Kolesnikov on 12.09.2023.
//

@testable import ImageFeed_ios
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterSpy()
        profileViewController.configure(profileViewPresenter)
        
        _ = profileViewController.view
        
        XCTAssertTrue(profileViewPresenter.viewDidLoadCalled)
    }
}
