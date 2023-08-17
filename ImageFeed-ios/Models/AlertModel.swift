//
//  AlertModel.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 16.08.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
