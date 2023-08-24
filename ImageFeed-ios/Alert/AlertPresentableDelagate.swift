//
//  AlertPresentableDelagate.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 16.08.2023.
//

import UIKit

protocol AlertPresentableDelagate: AnyObject {
    func present(alert: UIAlertController, animated flag: Bool)
}
