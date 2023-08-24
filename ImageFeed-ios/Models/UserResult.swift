//
//  UserResult.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 16.08.2023.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}
