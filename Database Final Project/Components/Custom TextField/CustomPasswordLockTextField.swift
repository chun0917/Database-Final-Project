//
//  CustomPasswordLockTextField.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/11/1.
//

import UIKit

class CustomPasswordLockTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setInit()
    }
    
    private func setInit() {
        isSecureTextEntry = true
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = bounds.height/10
        
        setupRightView()
    }
    
    private func setupRightView() {
        rightViewMode = .always
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.isSelected = true
        button.setImage(UIImage(icon: .closeEye), for: .selected)
        button.setImage(UIImage(icon: .openEye), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .gray
        rightView = button
        button.addTarget(self, action: #selector(secureBtnClicked(sender:)), for: .touchUpInside)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 50, y: 0, width: 50, height: 50)
    }
    
    @objc func secureBtnClicked(sender: UIButton) {
        sender.isSelected.toggle()
        isSecureTextEntry = sender.isSelected
    }
}
