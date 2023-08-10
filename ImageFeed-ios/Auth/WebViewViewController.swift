//
//  WebViewViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 02.08.2023.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    //MARK: - Outltes
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    //MARK: - Actions
    @IBAction func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    //MARK: - Variables
    weak var delegate: WebViewViewControllerDelegate?
    
    private struct WebKeys {
        static let clientId = "client_id"
        static let redirectUri = "redirect_uri"
        static let responseType = "response_type"
        static let scope = "scope"
    }
    
    private struct WebConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        static let code = "code"
        static let authPath = "/oauth/authorize/native"
    }
    
    //MARK: - Lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        loadWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
        updateProgress()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil
        )
    }
}

//MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == WebConstants.authPath,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == WebConstants.code })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

//MARK: - Functions
extension WebViewViewController {
    private func loadWebView() {
        var urlComponents = URLComponents(string: WebConstants.unsplashAuthorizeURLString)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: WebKeys.clientId, value: AccessKey),
            URLQueryItem(name: WebKeys.redirectUri, value: RedirectURI),
            URLQueryItem(name: WebKeys.responseType, value: WebConstants.code),
            URLQueryItem(name: WebKeys.scope, value: AccessScope)
        ]
        
        guard let url = urlComponents?.url else {
            return
        }
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
}

//MARK: - KVO
extension WebViewViewController {
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}
