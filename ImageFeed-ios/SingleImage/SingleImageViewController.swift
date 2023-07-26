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
    
    //MARK: - Variables
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            singleImageView.image = image
        }
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleImageView.image = image
    }
}
