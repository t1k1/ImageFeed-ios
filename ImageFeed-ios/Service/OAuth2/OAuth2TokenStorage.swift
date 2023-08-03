//
//  OAuth2TokenStorage.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 03.08.2023.
//

import Foundation

class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
