//
//  TabBarController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 17.08.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    private struct Keys {
        static let main = "Main"
        static let imagesListViewController = "ImagesListViewController"
        static let tabBarProfileImageName = "tab_profile_active"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storybord = UIStoryboard(name: Keys.main, bundle: .main)
        
        let imageListViewController = storybord.instantiateViewController(
            withIdentifier: Keys.imagesListViewController
        ) as? ImagesListViewController
        guard let imageListViewController = imageListViewController else { return }
        let imageListViewPresenter = ImagesListViewPresenter()
        imageListViewController.configure(imageListViewPresenter)
        
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenter()
        profileViewController.configure(profileViewPresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: Keys.tabBarProfileImageName),
            selectedImage: nil
        )
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
