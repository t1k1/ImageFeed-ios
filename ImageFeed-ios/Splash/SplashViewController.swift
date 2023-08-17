//
//  SplashViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 04.08.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    //MARK: - Variables
    private let ShowAuthSegueIdentifier = "authStoryBordID"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var alertPresenter: AlertPresenterProtocol?
    
    //MARK: - Lyfe cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            self.fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: ShowAuthSegueIdentifier, sender: nil)
        }
    }
}

//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthSegueIdentifier {
            
            guard let navigationController = segue.destination as? UINavigationController,
                  let viewController = navigationController.viewControllers[0] as? AuthViewController else {
                assertionFailure("Failed to prepare for \(ShowAuthSegueIdentifier)")
                return
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

//MARK: - Functions
extension SplashViewController {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchAuthToken(code)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        
        let tapBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tapBarController
    }
    
    private func fetchAuthToken(_ code: String){
        oauth2Service.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let token):
                    self.fetchProfile(token: token)
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    showErrorAlert()
                    
                    break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let data):
                    
                    profileImageService.fetchProfileImageURL(
                        token: token,
                        username: data.username
                    ){ _ in }
                    
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                case .failure(let error):
                    showErrorAlert(message: "Failure fetching profile. Error: \(error)")
                    break
            }
        }
        
    }
}

//MARK: - AlertPresenter
extension SplashViewController {
    private func showErrorAlert(message: String = "Не удалось войти в систему"){
        let alert = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Ок",
                               completion: { [weak self] in
            guard let self = self else {
                return
            }
            oauth2TokenStorage.token = nil
        })
        //TODO: Найти более изящный вариант
        let topController = UIApplication.topViewController()
        guard let topController = topController else { return }
        alertPresenter = AlertPresenter(delagate: topController as? AlertPresentableDelagate)
        
        alertPresenter?.show(alert)
    }
}

//MARK: - AlertPresentableDelagate
extension SplashViewController: AlertPresentableDelagate {
    func present(alert: UIAlertController, animated flag: Bool) {
        self.present(alert, animated: flag)
    }
}
