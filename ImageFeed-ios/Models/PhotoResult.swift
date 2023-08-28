//
//  PhotoResult.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 24.08.2023.
//

import Foundation

struct PhotosResult: Codable {
    let photos: [PhotoResult]
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int

    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    //    let likes: Int
    //    let updatedAt: String
    //    let color: String
    //    let blurHash: String
    //    let user":
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
        //        case likes
        //    case updatedAt = "updated_at"
        //    case color
        //    case blurHash = "blur_hash"
        //    case user
    }
}

struct UrlsResult: Codable {
    let full: String
    let thumb: String
    
    //    let raw: String
    //    let regular: String
    //    let small: String
}
