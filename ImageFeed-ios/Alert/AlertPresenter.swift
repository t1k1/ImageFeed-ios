//
//  AlertPresenter.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 16.08.2023.
//
import UIKit

final class AlertPresenter {
    private weak var delagate: AlertPresentableDelagate?
    
    init(delagate: AlertPresentableDelagate?) {
        self.delagate = delagate
    }
}

extension AlertPresenter: AlertPresenterProtocol {
    func show(_ alertArgs: AlertModel) {
        let alert = UIAlertController(title: alertArgs.title,
                                      message: alertArgs.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertArgs.buttonText, style: .default) { _ in
            alertArgs.completion()
        }
        alert.addAction(action)
        
        if let secondButtonText = alertArgs.secondButtonText {
            let secondAction = UIAlertAction(title: secondButtonText, style: .default) { _ in
                alertArgs.secondCompletion()
            }
            alert.addAction(secondAction)
        }
        
        delagate?.present(alert: alert, animated: true)
    }
}
