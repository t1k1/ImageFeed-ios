//
//  ProfileViewPresenter.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 12.09.2023.
//

import Foundation
import UIKit

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logOut()
    func updateAvatar()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    //MARK: - Variables
    weak var view: ProfileViewControllerProtocol?
    private let profileServise = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    //MARK: - Functions
    func viewDidLoad() {
        addButtonAction()
        updateProfileInfo()
    }
    
    func logOut() {
        OAuth2TokenStorage().token = nil
        WebViewViewController.cleanCookies()
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        
        view?.logOut(window: window)
    }
    
    func updateAvatar() {
        guard
            let avatarURL = profileImageService.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        
        let avatarPlaceholderImage = UIImage(named: "avatar_placeholder")
        
        view?.updateAvatar(url: url, placeholder: avatarPlaceholderImage ?? UIImage())
    }
}

//MARK: - Private functions
private extension ProfileViewPresenter {
    func addButtonAction() {
        if #available(iOS 14.0, *) {
            let logOutAction = UIAction(title: "showAlert") { [weak self] (ACTION) in
                guard let self = self else { return }
                view?.showAlertBeforeExit()
            }
            view?.addButtonActionAfterIos14(logOutAction: logOutAction)
        } else {
            view?.addButtonActionBeforeIos14(action: #selector(didTapButton))
        }
    }
    
    @objc
    func didTapButton() {
        view?.showAlertBeforeExit()
    }
    
    func updateProfileInfo() {
        view?.updateProfileInfo(profile: profileServise.profile)
    }
}
