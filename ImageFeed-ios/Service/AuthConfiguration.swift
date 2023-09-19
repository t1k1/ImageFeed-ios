//
//  Constants.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 01.08.2023.
//

import Foundation

let DefaultBaseURL = URL(string: "https://api.unsplash.com")
let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL?
    let authURLString: String
    let code = "code"
    let authPath = "/oauth/authorize/native"
    let clientId = "client_id"
    let redirectUriName = "redirect_uri"
    let responseType = "response_type"
    let scope = "scope"
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.AccessKey,
                                 secretKey: Constants.SecretKey,
                                 redirectURI: Constants.RedirectURI,
                                 accessScope: Constants.AccessScope,
                                 authURLString: unsplashAuthorizeURLString,
                                 defaultBaseURL: DefaultBaseURL)
    }
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        authURLString: String,
        defaultBaseURL: URL?
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}

private extension AuthConfiguration {
    enum Constants {
        static let AccessKey = "If08Gthwiy-OS5c2KShJb-2P-3kTs48ptGn9CWsONwE"
        static let SecretKey = "jpku-lNgG5f4NhQRUeMN-N9Lh1GttigbrKR6n5ykxLQ"
        static let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
        static let AccessScope = "public+read_user+write_likes"
    }
}
