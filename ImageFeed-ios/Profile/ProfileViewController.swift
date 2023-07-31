//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUpView()
    }
}

extension ProfileViewController {
    private func makeUpView() {
        let imageView = makeUpImageView(image: UIImage(named: "Avatar mock") ?? UIImage(systemName: "person.crop.circle.fill"))
        let labels = makeUpLabels()
        guard let descriptionLabel = labels["descriptionLabel"],
              let loginNameLabel = labels["loginNameLabel"],
              let nameLabel = labels["nameLabel"] else {
            return
        }
        let button = makeUpButton()
        
        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(nameLabel)
        view.addSubview(button)
        
        addAndActivateConstraints(avatarImageView: imageView,
                            descriptionLabel: descriptionLabel,
                            loginNameLabel: loginNameLabel,
                            nameLabel: nameLabel,
                            logOutButton: button)
    }
    
    private func makeUpImageView(image: UIImage?) -> UIImageView {
        let profileImageView = UIImageView(image: image)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return profileImageView
    }
    
    private func makeUpLabels() -> [String: UILabel] {
        let descriptionLabel = UILabel()
        let loginNameLabel = UILabel()
        let nameLabel = UILabel()
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .ypWhite
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = .ypGray
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        
        return [
            "descriptionLabel": descriptionLabel,
            "loginNameLabel": loginNameLabel,
            "nameLabel": nameLabel
        ]
    }
    
    private func makeUpButton() -> UIButton {
        let image = UIImage(named: "logout_image") ?? UIImage(systemName: "ipad.and.arrow.forward")!
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        
        if #available(iOS 14.0, *) {
            let logOutAction = UIAction(title: "Logout") { (ACTION) in
                // Выход из профиля
            }
            button.addAction(logOutAction, for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }

    @objc private func didTapButton() {
        // Выход из профиля
    }
    
    private func addAndActivateConstraints(avatarImageView: UIImageView,
                                     descriptionLabel: UILabel,
                                     loginNameLabel: UILabel,
                                     nameLabel: UILabel,
                                     logOutButton: UIButton) {
        
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
