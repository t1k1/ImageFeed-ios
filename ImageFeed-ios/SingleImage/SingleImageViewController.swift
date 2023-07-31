//
//  SingleImageViewController.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 25.07.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    //MARK: - Outltes
    @IBOutlet weak var singleImageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareButton: UIButton!
    
    //MARK: - Actions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        share(item: image)
    }
    
    //MARK: - Variables
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            singleImageView.image = image
            rescaleAndCenterImageInScrollView()
        }
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        singleImageView.image = image
        rescaleAndCenterImageInScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        rescaleAndCenterImageInScrollView()
    }
}

//MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.rescaleAndCenterImageInScrollView()
        }
    }
}

//MARK: - Functions
private extension SingleImageViewController {
    
    func rescaleAndCenterImageInScrollView() {
        let halfWidth = (scrollView.bounds.size.width - singleImageView.frame.size.width) / 2
        let halfHeight = (scrollView.bounds.size.height - singleImageView.frame.size.height) / 2
        scrollView.contentInset = .init(top: halfHeight, left: halfWidth, bottom: 0, right: 0)
    }
    
    func share(item: Any?) {
        guard let item = item else { return }
        
        let activityController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
