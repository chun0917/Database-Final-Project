//
//  CustomAddPasswordTextField.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/11/1.
//

import UIKit

class CustomTextField: UITextField {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setInit()
    }

    private func setInit() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = bounds.height/10
    }
}
