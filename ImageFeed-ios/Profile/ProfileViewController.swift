//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    //MARK: - Structure of string variables
    private struct Keys {
        static let main = "Main"
        static let logoutImageName = "logout_image"
        static let systemLogoutImageName = "ipad.and.arrow.forward"
        static let logOutActionName = "logOut"
        static let systemAvatarImageName = "person.crop.circle.fill"
        static let avatarPlaceholderImageName = "avatar_placeholder"
        static let authViewControllerName = "AuthViewController"
    }
    
    //MARK: - Variables
    private let profileServise = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let translucentGradient = TranslucentGradient()
    private var animationLayers = Set<CALayer>()
    
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        
        if #available(iOS 14.0, *) {
            let logOutAction = UIAction(title: Keys.logOutActionName) { (ACTION) in
                logOut()
            }
            button.addAction(logOutAction, for: .touchUpInside)
        } else {
            button.addTarget(ProfileViewController.self,
                             action: #selector(didTapButton),
                             for: .touchUpInside)
        }
        
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
    
        addSubViews()
        configureConstraints()
        addGradients()
        view.backgroundColor = .ypBlack
        updateProfileInfo(profile: profileServise.profile)
        
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
private extension ProfileViewController {
    @objc
    func didTapButton() {
        ProfileViewController.logOut()
    }
    
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
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    func updateAvatar() {
        guard
            let avatarURL = profileImageService.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        
        let avatarPlaceholderImage = UIImage(named: Keys.avatarPlaceholderImageName)
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: avatarPlaceholderImage
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success:
                    self.removeGradients()
                case .failure:
                    self.removeGradients()
                    avatarImageView.image = avatarPlaceholderImage
            }
        }
    }
    
    func addGradients() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
    }
    
    func removeGradients() {
        for gradient in animationLayers {
            gradient.removeFromSuperlayer()
        }
    }
    
    static func logOut() {
        OAuth2TokenStorage().token = nil
        WebViewViewController.cleanCookies()
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        
        let authViewController = UIStoryboard(name: Keys.main, bundle: .main).instantiateViewController(withIdentifier: Keys.authViewControllerName)
        window.rootViewController = authViewController
    }
}
