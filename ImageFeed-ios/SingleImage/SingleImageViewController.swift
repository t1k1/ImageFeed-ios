//
//  SingleImageViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    //MARK: - Outltes
    @IBOutlet private weak var singleImageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareButton: UIButton!
    
    //MARK: - Actions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        present(activityController, animated: true, completion: nil)
    }
    
    //MARK: - Variables
    var largeImageURL: URL?
    
    private var activityController = UIActivityViewController(activityItems: [], applicationActivities: nil)
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        UIBlockingProgressHUD.show()
        downloadImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let image = singleImageView.image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
}

//MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            
            guard let self = self,
                  let image = self.singleImageView.image  else {
                return
            }
            
            self.rescaleAndCenterImageInScrollView(image: image)
        }
    }
}

//MARK: - Functions
private extension SingleImageViewController {
    
    func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let halfWidth = (scrollView.bounds.size.width - singleImageView.frame.size.width) / 2
        let halfHeight = (scrollView.bounds.size.height - singleImageView.frame.size.height) / 2
        scrollView.contentInset = .init(top: halfHeight, left: halfWidth, bottom: 0, right: 0)
    }
    
    func downloadImage() {
        singleImageView.kf.setImage(with: largeImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
                case .success(let imageResult):
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                    activityController = UIActivityViewController(
                        activityItems: [imageResult.image as Any],
                        applicationActivities: nil
                    )
                case .failure:
                    showError()
            }
        }
    }
    
    func showError() {
        //TODO: - показать ошибку
        //        Добавьте также функцию showError(), которая показывает алерт об ошибке с текстом «Что-то пошло не так. Попробовать ещё раз?» и с кнопками «Не надо» (скрывает алерт) и «Повторить» (повторно выполняет kt.setImage — используйте блок кода выше; его можно положить в отдельную функцию и вызвать её при нажатии на «Повторить»).
    }
}
