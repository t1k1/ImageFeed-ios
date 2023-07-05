//
//  ViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 03.07.2023.
//

import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
//        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    /// определяет количество ячеек в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            print("ERROR! Ошибка привдения типов, создана пустая ячейка")
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    /// Метод для настройки ячейки
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        gradientBackGroundFor(cell.backgroundLabel)
        
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.cellImage.image = image
        cell.dateLabel.text = Date().dateTimeString
        
        let likeImageText = indexPath.row % 2 == 1 ? "Active" : "No Active"
        guard let likeImage = UIImage(named: likeImageText) else {
            return
        }
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    private func gradientBackGroundFor(_ label: UILabel) {
        let colorTop = UIColor(red: 26, green: 27, blue: 34, alpha: 0.1)
        let colorBottom = UIColor(red: 246, green: 27, blue: 34, alpha: 0.2)
        
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        backgroundLayer.locations = [0.0, 1.0]

        label.backgroundColor = UIColor.clear
        backgroundLayer.frame = view.frame
        label.layer.insertSublayer(backgroundLayer, at: 0)
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

extension ImagesListViewController: UITableViewDelegate {
    /// Отвечает за действия, которые будут выполнены при тапе по ячейке таблицы. «Адрес» ячейки, который содержится в indexPath, передаётся в качестве аргумента.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
