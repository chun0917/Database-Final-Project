//
//  Alert.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/6/24.
//

import UIKit

@MainActor class Alert: NSObject {
    
    /// 單一按鈕 Alert
    /// - Parameters:
    ///   - title: Alert 的標題
    ///   - message: Alert 的訊息
    ///   - vc: 要在哪個畫面跳出來
    ///   - isLeftAlign: Bool，message 文字是否靠左對齊
    ///   - confirmTitle: 按鈕的文字
    ///   - confirm: 按下按鈕後要做的事
    class func showAlertWith(title: String?,
                             message: String?,
                             vc: UIViewController,
                             isLeftAlign: Bool = false,
                             confirmTitle: String,
                             confirm: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if isLeftAlign {
                let sbvs = alertController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews
                let messageLabel: UILabel = sbvs[2] as! UILabel
                messageLabel.textAlignment = .left
            }
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                confirm?()
            }
            alertController.addAction(confirmAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// 確認、取消按鈕的 Alert
    /// - Parameters:
    ///   - title: Alert 的標題
    ///   - message: Alert 的訊息
    ///   - vc: 要在哪個畫面跳出來
    ///   - confirmTitle: 確認按鈕的文字
    ///   - cancelTitle: 取消按鈕的文字
    ///   - confirmActionStyle: 確認按鈕的 UIAlertAction.Style，預設為 .default
    ///   - confirm: 按下確認按鈕後要做的事
    ///   - cancel: 按下取消按鈕後要做的事
    class func showAlertWith(title: String?,
                             message: String?,
                             vc: UIViewController,
                             confirmTitle: String,
                             cancelTitle: String,
                             confirmActionStyle: UIAlertAction.Style = .default,
                             confirm: (() -> Void)? = nil,
                             cancel: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: confirmTitle, style: confirmActionStyle) { action in
                confirm?()
            }
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                cancel?()
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// 用來顯示 Error Message 的 Alert
    /// - Parameters:
    ///   - message: 要顯示的 Error Message
    ///   - vc: 要在哪個畫面跳出來
    ///   - confirmTitle: 確認按鈕的文字
    ///   - confirm: 按下確認按鈕後要做的事
    class func showAlertWithError(message: String,
                                  vc: UIViewController,
                                  confirmTitle: String,
                                  confirm: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: translate(.Error),
                                                    message: message,
                                                    preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
                confirm?()
            }
            alertController.addAction(confirmAction)
            vc.present(alertController, animated: true)
        }
    }
    
    /// 顯示 ActionSheet
    /// - Parameters:
    ///   - title: actionSheet 的標題
    ///   - message: actionSheet 的訊息
    ///   - isLeftAlign: Bool，message 文字是否靠左對齊
    ///   - options: actionSheet 內的選項
    ///   - vc: 要在哪個畫面跳出來
    ///   - confirm: 按下選項後要做的事
    class func showActionSheetWith(title: String? = nil,
                                   message: String? = nil,
                                   isLeftAlign: Bool = false,
                                   options: [String],
                                   vc: UIViewController,
                                   confirm: ((Int) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .actionSheet)
            if isLeftAlign {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                let messageText = NSMutableAttributedString(
                    string: message ?? "",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font : UIFont.boldSystemFont(ofSize: 12),
                        .foregroundColor : UIColor.black
                    ]
                )
                alertController.setAttributedMessage(value: messageText)
            }
            
            for option in options {
                let optionAction = UIAlertAction(title: option, style: .default) { _ in
                    let index = options.firstIndex(of: option)
                    confirm?(index!)
                }
                alertController.addAction(optionAction)
            }
            let cancelAction = UIAlertAction(title: translate(.Cancel), style: .cancel)
            alertController.addAction(cancelAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Toast

extension Alert {
    
    /// enum Toast 顯示時長
    enum ToastDisplayInterval {
        
        /// 顯示 Toast 1.5 秒後，移除 Toast
        case short
        
        /// 顯示 Toast 3 秒後，移除 Toast
        case long
        
        /// 自定義要顯示 Toast 幾秒後，移除 Toast
        case custom(Double)
    }
    
    /// 用 UIAlertController 顯示 Toast
    /// - Parameters:
    ///   - message: 要顯示在 Toast 上的訊息
    ///   - vc: 要在哪個畫面跳出來
    ///   - during: Toast 要顯示多久
    ///   - present: Toast 顯示出來後要做的事，預設為 nil
    ///   - dismiss: Toast 顯示消失後要做的事，預設為 nil
    class func showToastWith(message: String?,
                             vc: UIViewController,
                             during: ToastDisplayInterval,
                             present: (() -> Void)? = nil,
                             dismiss: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil,
                                                    message: message,
                                                    preferredStyle: .alert)
            vc.present(alertController, animated: true, completion: present)
            
            switch during {
            case .short:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    vc.dismiss(animated: true, completion: dismiss)
                }
            case .long:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    vc.dismiss(animated: true, completion: dismiss)
                }
            case .custom(let interval):
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    vc.dismiss(animated: true, completion: dismiss)
                }
            }
        }
    }
}
