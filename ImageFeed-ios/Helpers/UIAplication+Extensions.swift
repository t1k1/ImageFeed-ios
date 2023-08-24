//
//  UIAplication+Extensions.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 17.08.2023.
//

import UIKit

extension UIApplication {
    //Функция показывает текущий viewController
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
