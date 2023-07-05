//
//  ImagesListCell.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 04.07.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
}
