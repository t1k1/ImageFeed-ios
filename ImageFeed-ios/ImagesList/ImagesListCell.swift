//
//  ImagesListCell.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 04.07.2023.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    //MARK: - Outltes
    @IBOutlet private weak var backgroundLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var cellImage: UIImageView!
    
    //MARK: - Actions
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    //MARK: - Structure of string variables
    private struct Keys {
        static let reuseIdentifierName = "ImagesListCell"
        static let placeholderImageName = "image_cell_placeholder"
        static let likedImageName = "Active"
        static let unlikedImageName = "No Active"
    }
    
    //MARK: - Variables
    static let reuseIdentifier = Keys.reuseIdentifierName
    weak var delegate: ImagesListCellDelegate?
    
    //MARK: - Life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
}

//MARK: - Methods for configure cell
extension ImagesListCell {
    func configCell(using photoStringURL: String, with indexPath: IndexPath) -> Bool {
        gradientBackGroundFor(backgroundLabel)
        
        var status = false
        
        guard let photoURL = URL(string: photoStringURL) else {
            return status
        }
        
        let placeholderImage = UIImage(named: Keys.placeholderImageName)
        
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
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImageText = isLiked ? Keys.likedImageName : Keys.unlikedImageName
        guard let likeImage = UIImage(named: likeImageText) else { return }
        likeButton.setImage(likeImage, for: .normal)
    }
}
