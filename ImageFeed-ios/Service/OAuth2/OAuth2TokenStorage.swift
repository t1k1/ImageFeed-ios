//
//  OAuth2TokenStorage.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 03.08.2023.
//

import SwiftKeychainWrapper
import Foundation

class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue = newValue else {
                KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
                return
            }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: Keys.token.rawValue)
            guard isSuccess else {
                return
            }
        }
    }
}
