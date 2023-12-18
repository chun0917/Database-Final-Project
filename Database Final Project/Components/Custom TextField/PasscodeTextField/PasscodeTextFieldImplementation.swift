//
//  PasscodeTextFieldImplementation.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/11/28.
//

import UIKit

class PasscodeTextFieldImplementation: NSObject {
    
    weak var passcodeTextFieldImplementationDelegate: PasscodeTextFieldImplementationDelegate?
}

extension PasscodeTextFieldImplementation: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else {
            return false
        }
        return characterCount < passcodeTextFieldImplementationDelegate?.digitalLabelsCount ?? 0 || string == ""
    }
}

protocol PasscodeTextFieldImplementationDelegate: NSObjectProtocol {
    
    var digitalLabelsCount: Int { get }
    
    var digitalLabels: [UILabel] { get }
}
