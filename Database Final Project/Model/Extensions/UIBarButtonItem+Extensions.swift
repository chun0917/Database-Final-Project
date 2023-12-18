//
//  UIBarButtonItem+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/26.
//

import UIKit

extension UIBarButtonItem {

    static func addButton(_ target: Any?,
                          action: Selector,
                          title: String?,
                          imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        
        button.configuration?.imagePadding = 5
        
        button.addTarget(target, action: action, for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: button)

        return barButtonItem
    }
    
    /// 將原先 init 的 image 改為 [enum SFSymbols](x-source-tag://SFSymbols)，style 為 .done
    /// - Parameters:
    ///   - icon: [enum SFSymbols](x-source-tag://SFSymbols)
    convenience init(icon: SFSymbols, target: Any?, action: Selector?) {
        self.init(image: UIImage(icon: icon),
                  style: .done,
                  target: target,
                  action: action)
    }
}
