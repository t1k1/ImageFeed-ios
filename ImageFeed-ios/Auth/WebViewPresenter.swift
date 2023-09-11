//
//  WebViewPresenter.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 11.09.2023.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    private struct WebKeys {
        static let clientId = "client_id"
        static let redirectUri = "redirect_uri"
        static let responseType = "response_type"
        static let scope = "scope"
    }
    private struct WebConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        static let code = "code"
    }
    
    weak var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        var urlComponents = URLComponents(string: WebConstants.unsplashAuthorizeURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: WebKeys.clientId, value: AccessKey),
            URLQueryItem(name: WebKeys.redirectUri, value: RedirectURI),
            URLQueryItem(name: WebKeys.responseType, value: WebConstants.code),
            URLQueryItem(name: WebKeys.scope, value: AccessScope)
        ]
        guard let url = urlComponents?.url else { return }
        let request = URLRequest(url: url)
  
        view?.addEstimatedProgressObservtion()
        
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
