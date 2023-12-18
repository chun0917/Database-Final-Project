//
//  UIImage+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2023/2/4.
//

import UIKit

extension UIImage {
    
    /// 將原先 init 的 image 改為 [enum SFSymbols](x-source-tag://SFSymbols)
    /// - Parameters:
    ///   - icon: [enum SFSymbols](x-source-tag://SFSymbols)
    convenience init?(icon: SFSymbols) {
        self.init(systemName: icon.imageName)
    }
}
