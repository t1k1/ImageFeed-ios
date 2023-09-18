//
//  Photo.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 24.08.2023.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
