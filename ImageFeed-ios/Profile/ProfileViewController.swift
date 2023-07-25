//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    //MARK: - Outltes
    @IBOutlet private weak var avatarImageview: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var loginNameLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var logOutButton: UIButton!
    
    //MARK: - Actions
    @IBAction private func didTapLogOut() {
    }
}
