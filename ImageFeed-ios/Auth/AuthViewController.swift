//
//  AuthViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 02.08.2023.
//

import UIKit

final class AuthViewController: UIViewController {
    //MARK: - Variables
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    
    //MARK: - Lyfe cycle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

//MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
