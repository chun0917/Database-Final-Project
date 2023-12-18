//
//  UIView+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/2.
//

import UIKit

extension UIView {
    
    /// 載入 UINib，方便用來註冊 TableViewCell、CollectionViewCell
    /// - Returns: 對應的 UINib
    class func loadFromNib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
