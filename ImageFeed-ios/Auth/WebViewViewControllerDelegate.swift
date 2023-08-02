//
//  WebViewViewControllerDelegate.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 02.08.2023.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
