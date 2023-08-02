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
    
    //MARK: - Actions
    @IBAction func didTapBackButton() {
        
    }
    
    //MARK: - Variables
    weak var delegate: WebViewViewControllerDelegate?
    
    //MARK: - Lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        
        webView.load(request)
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
            //TODO: process code
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

//MARK: - Functions
private extension WebViewViewController {
    func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
