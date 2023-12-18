//
//  UIApplication+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/29.
//

import UIKit

extension UIApplication {
    
    /// Top visible viewcontroller
    var topMostVisibleViewController: UIViewController? {
        guard let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController as? UINavigationController else {
            return nil
        }
        return navigationController.visibleViewController
    }
}
