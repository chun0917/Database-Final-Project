//
//  UIColor+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/19.
//

import UIKit

extension UIColor {
    
    /// 將 Hex 的顏色表達，轉成 RGB 的 UIColor
    /// - Parameters:
    ///   - rgbValue: Hex 的顏色表達
    ///   - alpha: 透明度，預設為 1.0
    /// - Returns: 轉成 RGB 的 UIColor
    static func fromHex(rgbValue: UInt32, alpha: Double = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 256.0
        let blue = CGFloat(rgbValue & 0xFF) / 256.0
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
    }
    
    /// navigationBar 的顏色，色碼：systemIndigo
    static let navigationBar = UIColor.systemIndigo
}
