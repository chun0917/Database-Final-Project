//
//  PasscodeTextField.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/11/26.
//

import UIKit

class PasscodeTextField: UITextField {
    
    // MARK: - Variables
    
    /// 預設值
    var defaultValue: String = ""
    
    /// 圓角曲度
    var cornerRadius: CGFloat = 10
    
    /// 預設邊框的顏色
    var defaultBorderColor: UIColor = .gray
    
    /// 輸入後邊框的顏色，#13AD67
    var filledBorderColor: UIColor = .navigationBar
    
    /// 邊框寬度
    var borderWidth: CGFloat = 2
    
    /// 文字顏色
    var labelTextColor: UIColor = .black
    
    /// 文字字體大小
    var labelFontSize: UIFont = .systemFont(ofSize: 14)
    
    weak var passcodeDelegate: PasscodeTextFieldDelegate?
    
    private var implementation = PasscodeTextFieldImplementation()
    
    /// 是否已經設定過
    private var isConfigured: Bool = false
    
    /// 畫面上的六位數 Label
    private var digitLabels = [UILabel]()
    
    /// 單點手勢
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(openKeyboard))
        return recognizer
    }()
    
    @objc func openKeyboard() -> Bool {
        if !isEditing {
            clearPasscode()
            super.becomeFirstResponder()
        }
        return true
    }
    
    // MARK: - Override
    
    // 將 TextField 長按事件全部關閉
    internal override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    internal override func deleteBackward() {
        super.deleteBackward()
        guard let text = self.text else {
            return
        }
        
        switch text.count {
        case 0:
            digitalLabels[1].layer.borderColor = UIColor.gray.cgColor
        case 1:
            digitalLabels[2].layer.borderColor = UIColor.gray.cgColor
        case 2:
            digitalLabels[3].layer.borderColor = UIColor.gray.cgColor
        case 3:
            digitalLabels[4].layer.borderColor = UIColor.gray.cgColor
        case 4:
            digitalLabels[5].layer.borderColor = UIColor.gray.cgColor
        case 5:
            digitalLabels[5].layer.borderColor = UIColor.gray.cgColor
        default:
            break
        }
    }
    
    // MARK: - Function
    
    func configure(count: Int = 6) {
        guard isConfigured == false else {
            return
        }
        
        isConfigured.toggle()
        
        setupTextField()
        
        let labelsStackView = createLabelsStackView(with: count)
        addSubview(labelsStackView)
        
        digitLabels[0].layer.borderColor = filledBorderColor.cgColor
        
        addGestureRecognizer(tapRecognizer)
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func clearPasscode() {
        text = nil
        digitLabels.forEach { currentLabel in
            currentLabel.text = defaultValue
            currentLabel.layer.borderWidth = borderWidth
            currentLabel.layer.borderColor = defaultBorderColor.cgColor
        }
        digitalLabels[0].layer.borderColor = filledBorderColor.cgColor
        becomeFirstResponder()
    }
}

private extension PasscodeTextField {
    
    func setupTextField() {
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        borderStyle = .none
        isSecureTextEntry = true
        delegate = implementation
        implementation.passcodeTextFieldImplementationDelegate = self
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        for _ in 1 ... count {
            let label = createLabel()
            stackView.addArrangedSubview(label)
            digitLabels.append(label)
        }
        return stackView
    }
    
    func createLabel() -> UILabel {
        let label = UILabel()
        label.layer.cornerRadius = cornerRadius
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = labelTextColor
        label.font = labelFontSize
        label.isUserInteractionEnabled = true
        label.layer.masksToBounds = true
        label.text = defaultValue
        label.layer.borderColor = defaultBorderColor.cgColor
        label.layer.borderWidth = borderWidth
        return label
    }
    
    @objc func textDidChange() {
        guard let text = self.text, text.count <= digitLabels.count else { return }
        for labelIndex in 0 ..< digitLabels.count {
            let currentLabel = digitLabels[labelIndex]
            currentLabel.layer.borderColor = defaultBorderColor.cgColor
            if labelIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: labelIndex)
                currentLabel.text = isSecureTextEntry ? "●" : String(text[index])
            } else {
                currentLabel.text = defaultValue
            }
        }
        
        switch text.count {
        case 0:
            digitalLabels[0].layer.borderColor = filledBorderColor.cgColor
        case 1:
            digitalLabels[1].layer.borderColor = filledBorderColor.cgColor
        case 2:
            digitalLabels[2].layer.borderColor = filledBorderColor.cgColor
        case 3:
            digitalLabels[3].layer.borderColor = filledBorderColor.cgColor
        case 4:
            digitalLabels[4].layer.borderColor = filledBorderColor.cgColor
        case 5:
            digitalLabels[5].layer.borderColor = filledBorderColor.cgColor
        default:
            break
        }
        
        if text.count == digitLabels.count {
            passcodeDelegate?.didFinishEnter(code: text)
            resignFirstResponder()
        }
    }
}

// MARK: - PasscodeTextFieldImplementationDelegate

extension PasscodeTextField: PasscodeTextFieldImplementationDelegate {
    
    var digitalLabelsCount: Int {
        digitLabels.count
    }
    
    var digitalLabels: [UILabel] {
        digitLabels
    }
}

// MARK: - PasscodeTextFieldDelegate

protocol PasscodeTextFieldDelegate: NSObjectProtocol {
    
    func didFinishEnter(code: String)
}
