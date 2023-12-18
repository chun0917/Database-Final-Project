//
//  GenerateRandomPasswordViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/19.
//

import UIKit

class GenerateRandomPasswordViewController: BaseViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var securityPasswordGeneratorLabel: UILabel!
    @IBOutlet weak var closeWindowButton: UIButton!
    @IBOutlet weak var generatePasswordLabel: UILabel!
    @IBOutlet weak var passwordLengthLabel: UILabel!
    @IBOutlet weak var passwordLengthSlider: UISlider!
    @IBOutlet weak var AZCheckBoxButton: CheckBoxButtonView!
    @IBOutlet weak var azCheckBoxButton: CheckBoxButtonView!
    @IBOutlet weak var numberCheckBoxButton: CheckBoxButtonView!
    @IBOutlet weak var specialCharacterCheckBoxButton: CheckBoxButtonView!
    @IBOutlet weak var reGeneratePasswordButton: UIButton!
    @IBOutlet weak var useThisPasswordButton: UIButton!
    
    // MARK: - Variables
    
    var isChooseAZ_UpperCase: Bool = true // 是否包含 A-Z，預設為 true
    var isChooseAZ_LowerCase: Bool = true // 是否包含 a-z，預設為 true
    var isChooseNumber: Bool = true // 是否包含 0-9，預設為 true
    var isChooseSpecialCharacter: Bool = false // 是否包含特殊符號，預設為 false
    
    var delegate: GenerateRandomPasswordDelegate?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generatePasswordLabel.text = generateDefaultParameterPassword(length: 8)
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupCloseWindowButton()
        setupSecurityPasswordGeneratorLabel()
        setupGeneratePasswordLabel()
        setupPasswordLengthLabel()
        setupPasswordLengthSlider()
        setupAZCheckBoxButton()
        setupazCheckBoxButton()
        setupNumberCheckBoxButton()
        setupSpecialCharacterCheckBoxButton()
        setupReGeneratePasswordButton()
        setupUseThisPasswordButton()
    }
    
    /// 設定 `右上關閉按鈕` 的按鈕樣式
    private func setupCloseWindowButton() {
        closeWindowButton.setTitle(" ", for: .normal)
    }
    
    /// 設定 `左上安全密碼產生器` 的文字樣式
    private func setupSecurityPasswordGeneratorLabel() {
        securityPasswordGeneratorLabel.text = translate(.Security_Password_Generator)
        securityPasswordGeneratorLabel.tintColor = .systemTeal
    }
    
    /// 設定 `中間產生出來的密碼` 的文字樣式
    private func setupGeneratePasswordLabel() {
        generatePasswordLabel.text = ""
    }
    
    /// 設定 `密碼長度` 的文字樣式
    private func setupPasswordLengthLabel() {
        passwordLengthLabel.text = String.localizedStringWithFormat(translate(.Length),
                                                                    Int(passwordLengthSlider.value))
    }
    
    /// 設定 `密碼長度` 的滑桿樣式
    private func setupPasswordLengthSlider() {
        passwordLengthSlider.value = 8
        passwordLengthSlider.minimumValue = 4
        passwordLengthSlider.maximumValue = 20
        passwordLengthSlider.thumbTintColor = .systemTeal
        passwordLengthSlider.tintColor = .systemTeal
    }
    
    /// 設定 `A-Z CheckBox` 的按鈕樣式
    private func setupAZCheckBoxButton() {
        AZCheckBoxButton.setInit(index: 0,
                                 isChecked: isChooseAZ_UpperCase,
                                 labelText: "A-Z",
                                 delegate: self)
    }
    
    /// 設定 `a-z CheckBox` 的按鈕樣式
    private func setupazCheckBoxButton() {
        azCheckBoxButton.setInit(index: 1,
                                 isChecked: isChooseAZ_LowerCase,
                                 labelText: "a-z",
                                 delegate: self)
    }
    
    /// 設定 `0-9 CheckBox` 的按鈕樣式
    private func setupNumberCheckBoxButton() {
        numberCheckBoxButton.setInit(index: 2,
                                     isChecked: isChooseNumber,
                                     labelText: "0-9",
                                     delegate: self)
    }
    
    /// 設定 `特殊符號 CheckBox` 的按鈕樣式
    private func setupSpecialCharacterCheckBoxButton() {
        specialCharacterCheckBoxButton.setInit(index: 3,
                                               isChecked: isChooseSpecialCharacter,
                                               labelText: "!@#$%",
                                               delegate: self)
    }
    
    /// 設定 `重新產生密碼` 的按鈕樣式
    private func setupReGeneratePasswordButton() {
        reGeneratePasswordButton.setTitle(translate(.Re_Generate), for: .normal)
        reGeneratePasswordButton.tintColor = .white
        reGeneratePasswordButton.backgroundColor = .systemTeal
        reGeneratePasswordButton.layer.cornerRadius = reGeneratePasswordButton.bounds.height/6
    }
    
    /// 設定 `使用此密碼` 的按鈕樣式
    private func setupUseThisPasswordButton() {
        useThisPasswordButton.setTitle(translate(.Use_this_Password), for: .normal)
        useThisPasswordButton.tintColor = .white
        useThisPasswordButton.backgroundColor = .systemRed
        useThisPasswordButton.layer.cornerRadius = useThisPasswordButton.bounds.height/6
    }
    
    /// 產生隨機密碼
    /// - Parameters:
    ///   - length: 密碼長度，取決於 密碼長度 Silder 的值
    ///   - upperCase: 隨機產生的密碼內是否要包含大寫英文字母 (A-Z)
    ///   - lowerCase: 隨機產生的密碼內是否要包含小寫英文字母 (a-z)
    ///   - number: 隨機產生的密碼內是否要包含數字 (0-9)
    ///   - specialCharacter: 隨機產生的密碼內是否要包含特殊符號 (!@#$%)
    /// - Returns: 包含上述產生規則的隨機密碼
    func generateRandomPassword(length: Int,
                                upperCase: Bool,
                                lowerCase: Bool,
                                number: Bool,
                                specialCharacter: Bool) -> String {

        // All
        if upperCase && lowerCase && number && specialCharacter {
            return generateAllParametersPassword(length: length,
                                                 upperCase: upperCase,
                                                 lowerCase: lowerCase,
                                                 number: number,
                                                 specialCharacter: specialCharacter)
        }
        
        // 3 of All
        /*
         upperCase, lowerCase, number
         upperCase, lowerCase, specialCharacter
         upperCase, number, specialCharacter
         
         // lowerCase, upperCase, number -> 重複
         // lowerCase, upperCase, specialCharacter -> 重複
         lowerCase, number, specialCharacter
         
         // number, upperCase, lowerCase -> 重複
         // number, upperCase, specialCharacter -> 重複
         // number, lowerCase, specialCharacter -> 重複
         
         specialCharacter, upperCase, lowerCase
         // specialCharacter, upperCase, number -> 重複
         specialCharacter, lowerCase, number
         */
        
        if (upperCase && lowerCase && number) ||
            (upperCase && lowerCase && specialCharacter) ||
            (upperCase && number && specialCharacter) ||
            (lowerCase && number && specialCharacter) ||
            (specialCharacter && upperCase && lowerCase) ||
            (specialCharacter && lowerCase && number) {
            return generateThreeParametersPassword(length: length,
                                                   upperCase: upperCase,
                                                   lowerCase: lowerCase,
                                                   number: number,
                                                   specialCharacter: specialCharacter)
        }
        
        // 2 of All
        /*
         upperCase, lowerCase
         upperCase, number
         upperCase, specialCharacter
         
         // lowerCase, upperCase -> 重複
         lowerCase, number
         lowerCase, specialCharacter
         
         // number, upperCase -> 重複
         // number, lowerCase -> 重複
         number, specialCharacter
         
         // specialCharacter, upperCase -> 重複
         // specialCharacter, lowerCase -> 重複
         // specialCharacter, number -> 重複
         */
        if (upperCase && lowerCase) ||
            (upperCase && number) ||
            (upperCase && specialCharacter) ||
            (lowerCase && number) ||
            (lowerCase && specialCharacter) ||
            (number && specialCharacter) {
            return generateTwoParametersPassword(length: length,
                                                 upperCase: upperCase,
                                                 lowerCase: lowerCase,
                                                 number: number,
                                                 specialCharacter: specialCharacter)
        }
        
        // 1 of All
        if upperCase || lowerCase || number || specialCharacter {
            return generateOneParameterPassword(length: length,
                                                upperCase: upperCase,
                                                lowerCase: lowerCase,
                                                number: number,
                                                specialCharacter: specialCharacter)
        } else {
            // return Default Password Rules，UpperCase、LowerCase、Number
            return generateDefaultParameterPassword(length: 8)
        }
    }
    
    /// 產生隨機密碼，預設密碼產生規則 (A-Z、a-z、0-9)
    /// - Parameters:
    ///   - length: 密碼長度，取決於 密碼長度 Silder 的值
    /// - Returns: 包含上述產生規則的隨機密碼
    private func generateDefaultParameterPassword(length: Int) -> String {
        
        // Default Password Rules，UpperCase、LowerCase、Number
        let passwordCharacters: NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        
        var generateResults = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(passwordCharacters.length))
            var char = passwordCharacters.character(at: Int(rand))
            generateResults += NSString(characters: &char, length: 1) as String
        }
        
        return generateResults
    }
    
    /// 產生隨機密碼，只勾選一個密碼產生規則
    /// - Parameters:
    ///   - length: 密碼長度，取決於 密碼長度 Silder 的值
    ///   - upperCase: 隨機產生的密碼內是否要包含大寫英文字母 (A-Z)
    ///   - lowerCase: 隨機產生的密碼內是否要包含小寫英文字母 (a-z)
    ///   - number: 隨機產生的密碼內是否要包含數字 (0-9)
    ///   - specialCharacter: 隨機產生的密碼內是否要包含特殊符號 (!@#$%)
    /// - Returns: 包含上述產生規則的隨機密碼
    private func generateOneParameterPassword(length: Int,
                                              upperCase: Bool,
                                              lowerCase: Bool,
                                              number: Bool,
                                              specialCharacter: Bool) -> String {
        var passwordCharacters: NSString = ""
        
        var generateResults = ""
        
        // 1 of All
        if upperCase {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        } else if lowerCase {
            passwordCharacters = "abcdefghijklmnopqrstuvwxyz"
        } else if number {
            passwordCharacters = "0123456789"
        } else {
            passwordCharacters = "!@#$%"
        }
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(passwordCharacters.length))
            var char = passwordCharacters.character(at: Int(rand))
            generateResults += NSString(characters: &char, length: 1) as String
        }
        
        return generateResults
    }
    
    /// 產生隨機密碼，勾選兩個密碼產生規則
    /// - Parameters:
    ///   - length: 密碼長度，取決於 密碼長度 Silder 的值
    ///   - upperCase: 隨機產生的密碼內是否要包含大寫英文字母 (A-Z)
    ///   - lowerCase: 隨機產生的密碼內是否要包含小寫英文字母 (a-z)
    ///   - number: 隨機產生的密碼內是否要包含數字 (0-9)
    ///   - specialCharacter: 隨機產生的密碼內是否要包含特殊符號 (!@#$%)
    /// - Returns: 包含上述產生規則的隨機密碼
    private func generateTwoParametersPassword(length: Int,
                                               upperCase: Bool,
                                               lowerCase: Bool,
                                               number: Bool,
                                               specialCharacter: Bool) -> String {
        var passwordCharacters: NSString = ""
        
        var generateResults = ""
        
        // 2 of All
        /*
         upperCase, lowerCase
         upperCase, number
         upperCase, specialCharacter
         
         // lowerCase, upperCase -> 重複
         lowerCase, number
         lowerCase, specialCharacter
         
         // number, upperCase -> 重複
         // number, lowerCase -> 重複
         number, specialCharacter
         
         // specialCharacter, upperCase -> 重複
         // specialCharacter, lowerCase -> 重複
         // specialCharacter, number -> 重複
         */
        
        if upperCase && lowerCase {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        } else if upperCase && number {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        } else if upperCase && specialCharacter {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%"
        } else if lowerCase && number {
            passwordCharacters = "abcdefghijklmnopqrstuvwxyz0123456789"
        } else if lowerCase && specialCharacter {
            passwordCharacters = "abcdefghijklmnopqrstuvwxyz!@#$%"
        } else if number && specialCharacter {
            passwordCharacters = "0123456789!@#$%"
        }
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(passwordCharacters.length))
            var char = passwordCharacters.character(at: Int(rand))
            generateResults += NSString(characters: &char, length: 1) as String
        }
        
        return generateResults
    }
    
    /// 產生隨機密碼，勾選三個密碼產生規則
    /// - Parameters:
    ///   - length: 密碼長度，取決於 密碼長度 Silder 的值
    ///   - upperCase: 隨機產生的密碼內是否要包含大寫英文字母 (A-Z)
    ///   - lowerCase: 隨機產生的密碼內是否要包含小寫英文字母 (a-z)
    ///   - number: 隨機產生的密碼內是否要包含數字 (0-9)
    ///   - specialCharacter: 隨機產生的密碼內是否要包含特殊符號 (!@#$%)
    /// - Returns: 包含上述產生規則的隨機密碼
    private func generateThreeParametersPassword(length: Int,
                                                 upperCase: Bool,
                                                 lowerCase: Bool,
                                                 number: Bool,
                                                 specialCharacter: Bool) -> String {
        var passwordCharacters: NSString = ""
        
        var generateResults = ""
        
        // 3 of All
        /*
         upperCase, lowerCase, number
         upperCase, lowerCase, specialCharacter
         upperCase, number, specialCharacter
         
         // lowerCase, upperCase, number -> 重複
         // lowerCase, upperCase, specialCharacter -> 重複
         lowerCase, number, specialCharacter
         
         // number, upperCase, lowerCase -> 重複
         // number, upperCase, specialCharacter -> 重複
         // number, lowerCase, specialCharacter -> 重複
         
         specialCharacter, upperCase, lowerCase
         // specialCharacter, upperCase, number -> 重複
         specialCharacter, lowerCase, number
         */
        
        if upperCase && lowerCase && number {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        } else if upperCase && lowerCase && specialCharacter {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%"
        } else if upperCase && number && specialCharacter {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345678!@#$%"
        } else if lowerCase && number && specialCharacter {
            passwordCharacters = "abcdefghijklmnopqrstuvwxyz0123456789!@#$%"
        } else if specialCharacter && upperCase && lowerCase {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%"
        } else if specialCharacter && lowerCase && number {
            passwordCharacters = "abcdefghijklmnopqrstuvwxy0123456789!@#$%"
        }
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(passwordCharacters.length))
            var char = passwordCharacters.character(at: Int(rand))
            generateResults += NSString(characters: &char, length: 1) as String
        }
        
        return generateResults
    }
    
    /// 產生隨機密碼，勾選全部的密碼產生規則
    /// - Parameters:
    ///   - length: 密碼長度，取決於 密碼長度 Silder 的值
    ///   - upperCase: 隨機產生的密碼內是否要包含大寫英文字母 (A-Z)
    ///   - lowerCase: 隨機產生的密碼內是否要包含小寫英文字母 (a-z)
    ///   - number: 隨機產生的密碼內是否要包含數字 (0-9)
    ///   - specialCharacter: 隨機產生的密碼內是否要包含特殊符號 (!@#$%)
    /// - Returns: 包含上述產生規則的隨機密碼
    private func generateAllParametersPassword(length: Int,
                                               upperCase: Bool,
                                               lowerCase: Bool,
                                               number: Bool,
                                               specialCharacter: Bool) -> String {
        var passwordCharacters: NSString = ""
        
        var generateResults = ""
        
        // All
        if upperCase && lowerCase && number && specialCharacter {
            passwordCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%"
        }
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(passwordCharacters.length))
            var char = passwordCharacters.character(at: Int(rand))
            generateResults += NSString(characters: &char, length: 1) as String
        }
        
        return generateResults
    }
    
    // MARK: - IBAction
    
    @IBAction func closeWindowBtnClicked(sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func passwordLengthSilderChange(sender: UISlider) {
        DispatchQueue.main.async {
            self.passwordLengthLabel.text = String.localizedStringWithFormat(translate(.Length),
                                                                             Int(sender.value))
        }
    }
    
    @IBAction func reGeneratePasswordBtnClicked(sender: UIButton) {
        if isChooseAZ_UpperCase == false &&
            isChooseAZ_LowerCase == false &&
            isChooseNumber == false &&
            isChooseSpecialCharacter == false {
            Alert.showAlertWith(title: translate(.Please_check_at_least_one_password_generation_rule),
                                message: nil,
                                vc: self,
                                confirmTitle: translate(.Close),
                                confirm: nil)
            return
        }
        
        let passwordLength = Int(passwordLengthSlider.value)
        let results = generateRandomPassword(length: passwordLength,
                                             upperCase: isChooseAZ_UpperCase,
                                             lowerCase: isChooseAZ_LowerCase,
                                             number: isChooseNumber,
                                             specialCharacter: isChooseSpecialCharacter)
        
        DispatchQueue.main.async {
            self.generatePasswordLabel.text = results
        }
    }
    
    @IBAction func useThisPasswordBtnClicked(sender: UIButton) {
        guard let password = generatePasswordLabel.text else { return }
        self.dismiss(animated: true) {
            self.delegate?.postNewGeneratePassword(newPassword: password)
        }
    }
}

// MARK: - CheckBoxButtonViewDelegate

extension GenerateRandomPasswordViewController: CheckBoxButtonViewDelegate {
    
    func checkBox(_ checkBox: UIButton, didClickAt index: Int) {
        switch index {
        case 0:
            isChooseAZ_UpperCase = !isChooseAZ_UpperCase
        case 1:
            isChooseAZ_LowerCase = !isChooseAZ_LowerCase
        case 2:
            isChooseNumber = !isChooseNumber
        case 3:
            isChooseSpecialCharacter = !isChooseSpecialCharacter
        default:
            break
        }
    }
}

// MARK: - GenerateRandomPasswordDelegate

protocol GenerateRandomPasswordDelegate {
    
    func postNewGeneratePassword(newPassword: String) // 將產生的隨機密碼傳回新增新增密碼頁面
}
