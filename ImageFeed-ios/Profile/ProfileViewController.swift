//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    //MARK: - Variables
    private let profileServise = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        
        return label
    }()
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        
        return label
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        
        return label
    }()
    private let logOutButton: UIButton = {
        let image = UIImage(named: "logout_image") ?? UIImage(systemName: "ipad.and.arrow.forward")!
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        
        if #available(iOS 14.0, *) {
            let logOutAction = UIAction(title: "Logout") { (ACTION) in
                // Выход из профиля
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
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateProfileInfo(profile: profileServise.profile)
        addSubViews()
        configureConstraints()
    }
}

//MARK: - Functions
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
    
    @objc
    func didTapButton() {
        // Выход из профиля
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
        
        //Когда картинка берется из кэша, то появляется белый фон (под скруглениями)
        //Если очищать кэш картинки и каждый раз загружать, то все ок
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        let avatarPlaceholderImage = UIImage(named: "avatar_placeholder")
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: avatarPlaceholderImage,
            options: [.processor(processor)]
        )
    }
}
