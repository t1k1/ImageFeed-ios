//
//  ViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 03.07.2023.
//

import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    func configureImageList()
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showError()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol{
    
    //MARK: - Outltes
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Variables
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenter?
    private var presenter: ImagesListViewPresenterProtocol?
    
    func configure(_ presenter: ImagesListViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delagate: self)
        tableView?.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.configureImageList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as? IndexPath
            
            guard let viewController = viewController,
                  let indexPath = indexPath else {
                return
            }
            
            viewController.largeImageURL = presenter?.getLargeImageURL(from: indexPath)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.getPhotosCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.addGradient(size: CGSize(
            width: imageListCell.bounds.width,
            height: imageListCell.bounds.height
        ))
        
        imageListCell.delegate = self
        
        guard let presenter = presenter,
              let photo = presenter.getPhoto(indexPath: indexPath) else {
            return UITableViewCell()
        }
        
        let statusOfConfiguringCell = imageListCell.configCell(using: photo.thumbImageURL, with: indexPath, date: photo.createdAt)
        imageListCell.setIsLiked(photo.isLiked)
        if statusOfConfiguringCell {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        return imageListCell
    }
}

//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.fetchPhotosNextPage(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else { return CGFloat() }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        return presenter.getCellHeight(
            indexPath: indexPath,
            tableViewWidth: tableView.bounds.width,
            imageInsetsLeft: imageInsets.left,
            imageInsetsRight: imageInsets.right,
            imageInsetsTop: imageInsets.top,
            imageInsetsBottom: imageInsets.bottom
        )
    }
}

//MARK: - Functions
extension ImagesListViewController {
    func configureImageList() {
        imagesServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.updateTableView()
        }
        presenter?.updateTableView()
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func showError() {
        let alert = AlertModel(title: "Ошибка сети",
                               message: "Не удалось поставить/убрать лайк",
                               buttonText: "Ок",
                               completion: { [weak self] in
            guard let self = self else { return }
            dismiss(animated: true)
        })
        
        alertPresenter?.show(alert)
    }
}

//MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.changeLike(indexPath: tableView.indexPath(for: cell), cell: cell)
    }
}

//MARK: - AlertPresentableDelagate
extension ImagesListViewController: AlertPresentableDelagate {
    func present(alert: UIAlertController, animated flag: Bool) {
        self.present(alert, animated: flag)
    }
}
