//
//  Profile.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 15.08.2023.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    var loginName: String {
        get {
            "@\(username)"
        }
    }
    let bio: String
}
