//
//  WebViewControllerSpy.swift
//  ImageFeed-iosTests
//
//  Created by Aleksey Kolesnikov on 12.09.2023.
//

import ImageFeed_ios
import Foundation

final class WebViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    
    var loadRequestCalled = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func addEstimatedProgressObservtion() {
    
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}
