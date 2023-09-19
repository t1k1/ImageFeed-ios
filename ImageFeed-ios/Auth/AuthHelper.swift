//
//  AuthHelper.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 11.09.2023.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

class AuthHelper: AuthHelperProtocol {
    //MARK: - Variables
    let configuration: AuthConfiguration
    
    //MARK: - Initialization
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    //MARK: - Functions
    func authRequest() -> URLRequest? {
        let url = authUrl()
        guard let url = url else { return nil }
        
        return URLRequest(url: url)
    }
    
    func authUrl() -> URL? {
        var urlComponents = URLComponents(string: configuration.authURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: configuration.clientId, value: configuration.accessKey),
            URLQueryItem(name: configuration.redirectUri, value: configuration.redirectURI),
            URLQueryItem(name: configuration.responseType, value: configuration.code),
            URLQueryItem(name: configuration.scope, value: configuration.accessScope)
        ]
        
        return urlComponents?.url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == configuration.authPath,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == configuration.code })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
