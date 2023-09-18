//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit
import Kingfisher
import WebKit

public protocol ProfileViewControllerProtocol: AnyObject {
    func addButtonActionBeforeIos14(action: Selector)
    @available(iOS 14.0, *) func addButtonActionAfterIos14(logOutAction: UIAction)
    func showAlertBeforeExit()
    func logOut(window: UIWindow)
    func updateProfileInfo(profile: Profile?)
    func updateAvatar(url: URL, placeholder: UIImage)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    //MARK: - Structure of string variables
    private struct Keys {
        static let logoutImageName = "logout_image"
        static let systemLogoutImageName = "ipad.and.arrow.forward"
        static let systemAvatarImageName = "person.crop.circle.fill"
    }
    
    //MARK: - Variables
    private var profileImageServiceObserver: NSObjectProtocol?
    private let translucentGradient = TranslucentGradient()
    private var animationLayers = Set<CALayer>()
    private var alertPresenter: AlertPresenter?
    private var presenter: ProfileViewPresenterProtocol?
    
    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    //MARK: - Layout variables
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        
        return label
    }()
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        
        return label
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        
        return label
    }()
    private let logOutButton: UIButton = {
        let image = UIImage(named: Keys.logoutImageName) ?? UIImage(systemName: Keys.systemLogoutImageName)!
        
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "logOutButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        
        return button
    }()
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: Keys.systemAvatarImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delagate: self)
        
        view.backgroundColor = .ypBlack
        addSubViews()
        configureConstraints()
        addGradients()
        
        presenter?.viewDidLoad()
    }
}

//MARK: - Layout functions
private extension ProfileViewController {
    func addSubViews() {
        view.addSubview(avatarImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(nameLabel)
        view.addSubview(logOutButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            logOutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
            
        ])
    }
}

//MARK: - Functions
extension ProfileViewController {
    func updateProfileInfo(profile: Profile?) {
        guard let profile = profile else { return }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.updateAvatar()
        }
        presenter?.updateAvatar()
    }
    
    func updateAvatar(url: URL, placeholder: UIImage) {
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholder
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success:
                    self.removeGradients()
                case .failure:
                    self.removeGradients()
                    avatarImageView.image = placeholder
            }
        }
    }
    
    func addGradients() {
        let avatarGradient = translucentGradient.getGradient(
            size: CGSize(
                width: 70,
                height: 70
            ),
            cornerRadius: avatarImageView.layer.cornerRadius)
        avatarImageView.layer.addSublayer(avatarGradient)
        animationLayers.insert(avatarGradient)
        
        let nameLabelGradient = translucentGradient.getGradient(size: CGSize(
            width: nameLabel.bounds.width,
            height: nameLabel.bounds.height
        ))
        nameLabel.layer.addSublayer(nameLabelGradient)
        animationLayers.insert(nameLabelGradient)
        
        let descriptionLabelGradient = translucentGradient.getGradient(size: CGSize(
            width: descriptionLabel.bounds.width,
            height: descriptionLabel.bounds.height
        ))
        descriptionLabel.layer.addSublayer(descriptionLabelGradient)
        animationLayers.insert(descriptionLabelGradient)
        
        let loginLabelGradient = translucentGradient.getGradient(size: CGSize(
            width: loginNameLabel.bounds.width,
            height: loginNameLabel.bounds.height
        ))
        loginNameLabel.layer.addSublayer(loginLabelGradient)
        animationLayers.insert(loginLabelGradient)
    }
    
    func removeGradients() {
        for gradient in animationLayers {
            gradient.removeFromSuperlayer()
        }
    }
    
    func addButtonActionBeforeIos14(action: Selector) {
        logOutButton.addTarget(
            ProfileViewController.self,
            action: action,
            for: .touchUpInside
        )
    }
    
    @available(iOS 14.0, *)
    func addButtonActionAfterIos14(logOutAction: UIAction) {
        logOutButton.addAction(logOutAction, for: .touchUpInside)
    }
    
    func showAlertBeforeExit(){
        DispatchQueue.main.async {
            let alert = AlertModel(
                title: "Пока, пока!",
                message: "Уверены что хотите выйти?",
                buttonText: "Да",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.presenter?.logOut()
                },
                secondButtonText: "Нет",
                secondCompletion: { [weak self] in
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true)
                })
            
            self.alertPresenter?.show(alert)
        }
    }
    
    func logOut(window: UIWindow) {
        window.rootViewController = SplashViewController()
    }
}

//MARK: - AlertPresentableDelagate
extension ProfileViewController: AlertPresentableDelagate {
    func present(alert: UIAlertController, animated flag: Bool) {
        self.present(alert, animated: flag)
    }
}
