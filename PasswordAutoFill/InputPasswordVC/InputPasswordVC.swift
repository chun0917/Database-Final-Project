//
//  InputPasswordVC.swift
//  PasswordAutoFill
//
//  Created by 侯懿玲 on 2022/7/14.
//

import UIKit
import AuthenticationServices

class InputPasswordVC: ASCredentialProviderViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txfPassCode: PasscodeTextField!
    @IBOutlet weak var vActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var biometricLabel: UILabel!
    @IBOutlet weak var biometricButton: UIButton!
    
    // MARK: - Variables
    
    var code: String = "" // 用來取得輸入的密碼
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        checkFinishInitialFlow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callLocalAuthentication()
    }
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
     */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        SingletonPatternOfURLText.shared.autofillURLText = serviceIdentifiers[0].identifier
        print("AutoFill URL：", serviceIdentifiers[0].identifier)
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        
        setupBiometricUI(labelIsHidden: false, buttonIsHidden: false)
        
        // Label
        lbTitle.text = translate(.Extension_PassCode)
        
        // TextField
        setupPassCodeTextField()
        
        // Button
        setupBtnLogin(buttonTitleColor: .white,
                      buttonBackgroundColor: .systemGray4,
                      buttonEnabled: false)
        
        // vActivityIndicator
        setupvActivityIndicator(isHidden: true) // 按下建立按鈕後，會出現的轉圈過場
    }
    
    private func setupPassCodeTextField() {
        txfPassCode.passcodeDelegate = self
        txfPassCode.configure(count: 6)
        if UserPreferences.shared.isEnableLocalAuthentication == false {
            txfPassCode.becomeFirstResponder()
        }
    }
    
    /// 設定 UIvActivityIndicator 樣式
    /// - Parameter isHidden: 是否顯示 UIvActivityIndicator，預設為 true
    private func setupvActivityIndicator(isHidden: Bool = true) {
        vActivityIndicator.isHidden = isHidden
    }
    
    /// 設定 `登入按鈕` 的 Button 樣式
    /// - Parameters:
    ///   - buttonTitleColor: Button 文字顏色，預設為 UIColor.white
    ///   - buttonBackgroundColor: Button 背景色，預設為 UIColor.systemGray4
    ///   - buttonEnabled: Button 是否能用，預設為 false
    private func setupBtnLogin(buttonTitleColor: UIColor = .white,
                               buttonBackgroundColor: UIColor = .systemGray4,
                               buttonEnabled: Bool = false) {
        btnLogin.setTitle(translate(.Extension_Login), for: .normal)
        btnLogin.layer.cornerRadius = btnLogin.bounds.height/6
        btnLogin.backgroundColor = buttonBackgroundColor
        btnLogin.setTitleColor(buttonTitleColor, for: .normal)
        btnLogin.isUserInteractionEnabled = buttonEnabled
    }
    
    /// 設定生物辨識按鈕及文字
    /// - Parameters:
    ///   - labelIsHidden: Bool，biometricLabel 是否顯示
    ///   - buttonIsHidden: Bool，biometricButton 是否顯示
    private func setupBiometricUI(labelIsHidden: Bool, buttonIsHidden: Bool) {
        setupBiometricLabel(isHidden: labelIsHidden)
        setupBiometricButton(isHidden: buttonIsHidden)
    }
    
    /// 設定生物辨識按鈕的文字
    private func setupBiometricLabel(isHidden: Bool = false) {
        // 設定`產生新密碼` 底線樣式
        let foregroundColor: UIColor = UserPreferences.shared.isEnableLocalAuthentication ? .purple : .gray
        let textAttributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 17),             // 文字大小、字體樣式
            .foregroundColor : foregroundColor,                // 文字顏色
            .underlineStyle : NSUnderlineStyle.single.rawValue // .single 單條底線 .double .thick 單條粗底線
        ]
        let attributedText = NSMutableAttributedString(
            string: translate(.Sign_in_with_biometrics),
            attributes: textAttributes
        )
        biometricLabel.attributedText = attributedText
        biometricLabel.isHidden = isHidden
    }
    
    /// 設定生物辨識的按鈕
    private func setupBiometricButton(isHidden: Bool = false) {
        biometricButton.setTitle("", for: .normal)
        biometricButton.isHidden = isHidden
        if UserPreferences.shared.isEnableLocalAuthentication {
            biometricButton.isEnabled = true
        } else {
            biometricButton.isEnabled = false
        }
    }
    
    // MARK: - Function
    
    private func checkFinishInitialFlow() {
        if UserPreferences.shared.isFinishFirstSetting == false {
            Alert.showAlertWith(title: translate(.Warnings),
                                message: "請先完成 TekPass Keep 的初始化流程，才能使用密碼自動填入服務",
                                vc: self,
                                confirmTitle: translate(.Confirm)) {
                self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                       code: ASExtensionError.userCanceled.rawValue))
            }
        }
    }
    
    // MARK: - Call Local Authentication
    
    private func callLocalAuthentication() {
        if UserPreferences.shared.isEnableLocalAuthentication &&
            UserPreferences.shared.isFinishFirstSetting {
            AuthenticationManager.shared.evaluateUserWithBiometrics(reason: translate(.Please_enter_your_password_or_use_biometrics_to_unlock)) { results in
                switch results {
                case .success(_):
                    DispatchQueue.main.async {
                        self.setupBiometricUI(labelIsHidden: true, buttonIsHidden: true)
                        self.btnLogin.isHidden = true
                        self.txfPassCode.resignFirstResponder()
                        self.vActivityIndicator.isHidden = false
                        self.vActivityIndicator.startAnimating()
                        
                        let autoVC = AutoFillViewController()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            // 取消拖曳返回之前頁面
                            autoVC.isModalInPresentation = true
                            self.present(autoVC, animated: true) {
                                self.vActivityIndicator.stopAnimating()
                            }
                        }
                    }
                case .failure(let failure):
                    switch failure.code {
                    case .authenticationFailed:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.authenticationFailed")
                    case .userCancel:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.userCancel")
                    case .userFallback:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.userFallback")
                    case .systemCancel:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.systemCancel")
                    case .passcodeNotSet:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.passcodeNotSet")
                    case .biometryNotAvailable:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.biometryNotAvailable")
                    case .biometryNotEnrolled:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.biometryNotEnrolled")
                    case .biometryLockout:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.biometryLockout")
                    case .touchIDNotAvailable:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.touchIDNotAvailable")
                    case .touchIDNotEnrolled:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.touchIDNotEnrolled")
                    case .touchIDLockout:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.touchIDLockout")
                    case .appCancel:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.appCancel")
                    case .invalidContext:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.invalidContext")
                    case .notInteractive:
                        print("使用者使用生物辨識解除鎖定失敗，LAError.Code.notInteractive")
                    @unknown default:
                        print("使用者使用生物辨識解除鎖定失敗，unknown LAError.Code：", failure.code)
                    }
                }
            }
        } else {
            print("使用者尚未啟用生物辨識")
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        if code == UserPreferences.shared.accessSixNumber {
            DispatchQueue.main.async {
                self.setupBiometricUI(labelIsHidden: true, buttonIsHidden: true)
                self.btnLogin.isHidden = true
                self.vActivityIndicator.isHidden = false
                self.vActivityIndicator.startAnimating()
                
                let autoVC = AutoFillViewController()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // 取消拖曳返回之前頁面
                    autoVC.isModalInPresentation = true
                    self.present(autoVC, animated: true) {
                        self.vActivityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            Alert.showAlertWith(title: "",
                                message: translate(.Extension_The_entered_passwords_do_not_match),
                                vc: self,
                                confirmTitle: translate(.Close)) {
                self.txfPassCode.clearPasscode()
            }
        }
    }
    
    @IBAction func biometricBtnClicked(_ sender: UIButton) {
        if UserPreferences.shared.isEnableLocalAuthentication &&
            UserPreferences.shared.isFinishFirstSetting {
            callLocalAuthentication()
        } else {
            Alert.showAlertWith(title: translate(.Warnings),
                                message: "若欲使用生物辨識登入，請至設定頁面啟用。",
                                vc: self,
                                confirmTitle: translate(.Confirm))
        }
    }
    
    @IBAction func touchBtnCancel(_ sender: UIBarButtonItem) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                               code: ASExtensionError.userCanceled.rawValue))
        /*
         // 退回自定義的 UIViewController
         // self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
         */
    }
}

// MARK: - PasscodeTextFieldDelegate

extension InputPasswordVC: PasscodeTextFieldDelegate {
    
    func didFinishEnter(code: String) {
        self.code = code
        if code.count == 6 {
            if code == UserPreferences.shared.accessSixNumber {
                #if DEBUG
                print("登入可用")
                #endif
                DispatchQueue.main.async {
                    self.setupBiometricUI(labelIsHidden: true, buttonIsHidden: true)
                    self.btnLogin.isHidden = true
                    self.vActivityIndicator.isHidden = false
                    self.vActivityIndicator.startAnimating()
                    
                    let autoVC = AutoFillViewController()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // 取消拖曳返回之前頁面
                        autoVC.isModalInPresentation = true
                        self.present(autoVC, animated: true) {
                            self.vActivityIndicator.stopAnimating()
                        }
                    }
                }
            } else {
                Alert.showAlertWith(title: "",
                                    message: translate(.Extension_The_entered_passwords_do_not_match),
                                    vc: self,
                                    confirmTitle: translate(.Close)) {
                    self.txfPassCode.clearPasscode()
                }
            }
        } else {
            #if DEBUG
            print("登入不可用")
            #endif
            DispatchQueue.main.async {
                self.setupBtnLogin(buttonBackgroundColor: .systemGray4, buttonEnabled: false)
            }
        }
    }
}

/*
 present 取消拖曳返回之前頁面
 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/ios-13-%E7%9A%84-present-modally-%E8%AE%8A%E6%88%90%E6%9B%B4%E6%96%B9%E4%BE%BF%E7%9A%84%E5%8D%A1%E7%89%87%E8%A8%AD%E8%A8%88-fb6b31f0e20e
 */
