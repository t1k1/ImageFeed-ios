//
//  ProfileViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    //MARK: - Outltes
    @IBOutlet weak var avatarImageview: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    //MARK: - Actions
    @IBAction func didTapLogOut() {
    }
}
