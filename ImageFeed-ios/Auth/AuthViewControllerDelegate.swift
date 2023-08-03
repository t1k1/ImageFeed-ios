//
//  AuthViewControllerDelegate.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 03.08.2023.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
