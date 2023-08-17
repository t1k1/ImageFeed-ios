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
    weak var delegate: AuthViewControllerDelegate?
    
    //MARK: - Lyfe cycle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(ShowWebViewSegueIdentifier)")
                return
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
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

//MARK: - AlertPresentableDelagate
extension AuthViewController: AlertPresentableDelagate {
    func present(alert: UIAlertController, animated flag: Bool) {
            self.present(alert, animated: flag)
    }
}
