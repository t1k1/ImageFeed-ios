//
//  ImagesListCell.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 04.07.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    //MARK: - Variables
    static let reuseIdentifier = "ImagesListCell"
    
    //MARK: - Outltes
    @IBOutlet private weak var backgroundLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var cellImage: UIImageView!
    
    //MARK: - Life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
}

//MARK: - Methods
extension ImagesListCell {
    func configCell(using photoStringURL: String, with indexPath: IndexPath) -> Bool {
        gradientBackGroundFor(backgroundLabel)
        
        var status = false
        
        guard let photoURL = URL(string: photoStringURL) else {
            return status
        }
        
        let placeholderImage = UIImage(named: "image_cell_placeholder")
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: photoURL,
            placeholder: placeholderImage
        ) { result in
            switch result {
                case .success(_):
                    status = true
                case .failure(let error):
                    print("!ОШИБКА загрузки картинки \(error)")
            }
        }
        
        dateLabel.text = Date().dateTimeString
        
        let likeImageText = indexPath.row % 2 == 0 ? "Active" : "No Active"
        guard let likeImage = UIImage(named: likeImageText) else {
            return status
        }
        likeButton.setImage(likeImage, for: .normal)
        
        return status
    }
    
    private func gradientBackGroundFor(_ label: UILabel) {
        if label.layer.sublayers?.count ?? 0 > 0 { return }
        
        let colorTop = UIColor(red: 26, green: 27, blue: 34, alpha: 0.0)
        let colorBottom = UIColor(red: 26, green: 27, blue: 34, alpha: 0.2)
        
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.frame = label.bounds
        backgroundLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        backgroundLayer.locations = [0.0, 1]
        backgroundLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        backgroundLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        label.backgroundColor = UIColor.clear
        
        label.layer.insertSublayer(backgroundLayer, at: 0)
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
