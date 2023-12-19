//
//  RegisterViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2023/12/16.
//

import UIKit
import FMDB

class RegisterViewController: BaseViewController {
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomPasswordLockTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomPasswordLockTextField!
    @IBOutlet var requiredLabels: [UILabel]!
    @IBOutlet weak var emailCountLabel: UILabel!
    @IBOutlet weak var phoneCountLabel: UILabel!
    @IBOutlet weak var passwordCountLabel: UILabel!
    @IBOutlet weak var confirmPasswordCountLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: - Variables
    
    var database: FMDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        // NavigationBar
        setupNavigationBarView()
        
        // TabBar
        setupTabBarStyle()
        
        // TextField
        setupTextFields()
        
        // Label
        setupLabels()
        
        // Button
        registerButton.setTitle(translate(.Register), for: .normal)
        registerButton.tintColor = .white
        registerButton.layer.cornerRadius = registerButton.bounds.height/6
    }
    
    /// 判斷是否成功連線至資料庫
    func connectDB() -> Bool {
        var isOpen: Bool = false
        self.database = FMDatabase(path: UserPreferences.shared.databasePath)
        if self.database != nil {
            if self.database.open() {
                isOpen = true
            } else {
                print("未連線至資料庫")
            }
        }
        return isOpen
    }
    
    // 信箱正則
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // 手機正則
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^09[0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    // 判斷信箱是否已被註冊
    func isEmailRegistered(email: String) -> Bool{
        var isEmailRegistered = false
        if connectDB() {
            let query = "SELECT email FROM USER WHERE email = ?"
            do {
                let results: FMResultSet = try database.executeQuery(query, values: [email])
                while results.next() {
                    isEmailRegistered = true
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return isEmailRegistered
    }
    
    // 判斷手機是否已被註冊
    func isPhoneRegistered(phone: String) -> Bool{
        var isPhoneRegistered = false
        if connectDB() {
            let query = "SELECT phone FROM USER WHERE phone = ?"
            do {
                let results: FMResultSet = try database.executeQuery(query, values: [phone])
                while results.next() {
                    isPhoneRegistered = true
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return isPhoneRegistered
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.Register),
                               displayMode: .noRightButtons)
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        // 信箱
        emailTextField.placeholder = translate(.Email)
        emailTextField.delegate = self
        
        // 手機
        phoneTextField.placeholder = translate(.Phone)
        phoneTextField.delegate = self
        
        // 密碼
        passwordTextField.placeholder = translate(.Password)
        passwordTextField.delegate = self
        
        // 確認密碼
        confirmPasswordTextField.placeholder = translate(.Confirm_password)
        confirmPasswordTextField.delegate = self
    }
    
    /// 設定Label 樣式
    private func setupLabels() {
        requiredLabels[0].text = translate(.Required)
        requiredLabels[1].text = translate(.Required)
        requiredLabels[2].text = translate(.Required)
        requiredLabels[3].text = translate(.Required)
        emailCountLabel.text = "\(0)/50"
        phoneCountLabel.text = "\(0)/10"
        passwordCountLabel.text = "\(0)/50"
        confirmPasswordCountLabel.text = "\(0)/50"
    }
    
    @IBAction func registerAccount(_ sender: Any) {
        if (emailTextField.text == "" || phoneTextField.text == "" || passwordTextField.text == "" || confirmPasswordTextField.text == "") {
            Alert.showToastWith(message: translate(.Please_make_sure_all_required_fields_are_entered),
                                vc: self,
                                during: .short)
        }
        else{
            if (isValidEmail(email: emailTextField.text!) == false || (isValidPhoneNumber(phoneNumber: phoneTextField.text!) == false)) {
                Alert.showToastWith(message: translate(.Please_input_valid_email_or_phone),
                                    vc: self,
                                    during: .short)
            }
            else if (passwordTextField.text != confirmPasswordTextField.text) {
                Alert.showToastWith(message: translate(.Password_do_not_match),
                                    vc: self,
                                    during: .short)
            }
            else{
                if (isEmailRegistered(email: emailTextField.text!) == true) {
                    Alert.showToastWith(message: translate(.Email_is_already_registered), vc: self, during: .short)
                }
                else if (isPhoneRegistered(phone: phoneTextField.text!) == true) {
                    Alert.showToastWith(message: translate(.Phone_is_already_registered), vc: self, during: .short)
                }
                else {
                    LocalDatabase.shared.register(id: UUID().uuidString, email: emailTextField.text!, phone: phoneTextField.text!, password: passwordTextField.text!, table: .user)
                    Alert.showToastWith(message: translate(.Register_success),
                                        vc: self,
                                        during: .short, dismiss: {
                        self.popToRootViewController()
                    })
                }
            }
        }
    }
    
    @IBAction func textFieldDidChanged(_ sender: UITextField) {
        guard let textFieldText = sender.text else {
            return
        }
        switch sender {
        case emailTextField:
            DispatchQueue.main.async {
                self.emailCountLabel.text = "\(textFieldText.count)/50"
            }
        case phoneTextField:
            DispatchQueue.main.async {
                self.phoneCountLabel.text = "\(textFieldText.count)/10"
            }
        case passwordTextField:
            DispatchQueue.main.async {
                self.passwordCountLabel.text = "\(textFieldText.count)/50"
            }
        case confirmPasswordTextField:
            DispatchQueue.main.async {
                self.confirmPasswordCountLabel.text = "\(textFieldText.count)/50"
            }
        default:
            break
        }
    }
    
    @objc func backButtonAction(){
        if (emailTextField.text == "" &&
            phoneTextField.text == "" &&
            passwordTextField.text == "" &&
            confirmPasswordTextField.text == "") {
            print("輸入框為空值")
            popToRootViewController()
        }
        else {
            print("輸入框有值")
            Alert.showAlertWith(title: translate(.Cancel_register),
                                message: translate(.The_currently_entered_data_has_not_been_saved_Do_you_want_to_leave_this_screen),
                                vc: self,
                                confirmTitle: translate(.Confirm),
                                cancelTitle: translate(.Cancel)) {
                print("pop to top vc")
                self.popViewController()
            } cancel: {
                print("will edit")
            }
        }
    }
}
// MARK: - NavigationBarViewDelegate

extension RegisterViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        backButtonAction()
    }
    
    func btnRightClicked(index: Int) {
        //
    }
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        switch textField {
        case emailTextField:
            return count <= 50
        case phoneTextField:
            return count <= 10
        case passwordTextField:
            return count <= 50
        case confirmPasswordTextField:
            return count <= 50
        default:
            return true
        }
    }
}
