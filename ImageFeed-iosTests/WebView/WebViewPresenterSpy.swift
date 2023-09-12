//
//  WebViewPresenterSpy.swift
//  ImageFeed-iosTests
//
//  Created by Aleksey Kolesnikov on 12.09.2023.
//

import ImageFeed_ios
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
