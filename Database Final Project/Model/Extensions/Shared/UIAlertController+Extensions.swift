//
//  UIAlertController+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2023/2/8.
//

import UIKit

extension UIAlertController {
    
    /// 設定 UIAlertController message 的 attributedMessage
    /// - Parameters:
    ///   - value: attributedMessage
    func setAttributedMessage(value: Any?) {
        self.setValue(value, forKey: "attributedMessage")
    }
}
