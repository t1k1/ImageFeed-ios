//
//  ProfileViewPresenterSpy.swift
//  ImageFeed-iosTests
//
//  Created by Aleksey Kolesnikov on 13.09.2023.
//

import Foundation
import ImageFeed_ios

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ImageFeed_ios.ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logOut() {
        
    }
    
    func updateAvatar() {
        
    }
    
    
}
