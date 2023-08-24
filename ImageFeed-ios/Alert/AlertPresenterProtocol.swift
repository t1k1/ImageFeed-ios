//
//  AlertPresenterProtocol.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 16.08.2023.
//

import Foundation

protocol AlertPresenterProtocol: AnyObject {
    func show(_ alertArgs: AlertModel)
}
