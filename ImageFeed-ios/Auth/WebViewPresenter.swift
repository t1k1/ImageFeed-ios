//
//  WebViewPresenter.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 11.09.2023.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    //MARK: - Variables
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    //MARK: - Initialization
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    //MARK: - Functions
    func viewDidLoad() {
        let request = authHelper.authRequest()
        guard let request = request else { return }
        view?.load(request: request)
        
        view?.addEstimatedProgressObservtion()
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
