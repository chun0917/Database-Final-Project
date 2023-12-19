//
//  ResetPasswordViewController.swift
//  Database Final Project
//
//  Created by 呂淳昇 on 2023/12/18.
//

import UIKit
import FMDB

class ChangePasswordViewController: BaseViewController {
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var originPasswordTextField: CustomPasswordLockTextField!
    @IBOutlet weak var newPasswordTextField: CustomPasswordLockTextField!
    @IBOutlet weak var confirmNewPasswordTextField: CustomPasswordLockTextField!
    @IBOutlet var requiredLabels: [UILabel]!
    @IBOutlet weak var originPasswordCountLabel: UILabel!
    @IBOutlet weak var newPasswordCountLabel: UILabel!
    @IBOutlet weak var confirmNewPasswordCountLabel: UILabel!
    
    var database: FMDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupUI(){
        setupNavigationBarView()
        setupTextFields()
        setupLabels()
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
    
    func changePassword(id: String, originPassword: String, newPassword: String) -> Bool {
        var isOriginPasswordCorrect = false
        if connectDB() {
            let query = "SELECT password FROM USER WHERE userID = ?"
            do {
                let result: FMResultSet = try database.executeQuery(query, values: [UserPreferences.shared.userID])
                while result.next() {
                    if (originPassword != result.string(forColumn: "password")!){
                        Alert.showToastWith(message: translate(.Origin_password_is_incorrect), vc: self, during: .short)
                    }
                    else {
                        isOriginPasswordCorrect = true
                        let sqlCommand = "UPDATE USER SET password = ? WHERE userID = ?"
                        do {
                            try database.executeUpdate(sqlCommand, values: [newPassword,UserPreferences.shared.userID])
                        } catch {
                            print(error.localizedDescription)
                        }
                        database.close()
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        return isOriginPasswordCorrect
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.Change_Password),
                               displayMode: .leftRight,
                               btnIcon2: .save)
    }

    /// 設定 TextField 樣式
    private func setupTextFields() {
        // 輸入原密碼
        originPasswordTextField.placeholder = translate(.Input_origin_password)
        originPasswordTextField.delegate = self
        
        // 輸入新密碼
        newPasswordTextField.placeholder = translate(.Input_new_password)
        newPasswordTextField.delegate = self
        
        // 確認新密碼
        confirmNewPasswordTextField.placeholder = translate(.Confirm_new_password)
        confirmNewPasswordTextField.delegate = self
    }
    
    /// 設定 Label 樣式
    private func setupLabels() {
        requiredLabels[0].text = translate(.Required)
        requiredLabels[1].text = translate(.Required)
        requiredLabels[2].text = translate(.Required)
        originPasswordCountLabel.text = "\(0)/50"
        newPasswordCountLabel.text = "\(0)/50"
        confirmNewPasswordCountLabel.text = "\(0)/50"
    }
    
    // MARK: - NavigationBarButtonItems Actions
    
    @objc func backButtonAction() {
        if (originPasswordTextField.text == "" &&
            newPasswordTextField.text == "" &&
            confirmNewPasswordTextField.text == "") {
            print("輸入框為空值")
            popToRootViewController()
        } else {
            print("輸入框有值")
            Alert.showAlertWith(title: translate(.Cancel_Add),
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
    
    @objc func saveButtonAction() {
        if (originPasswordTextField.text == "" ||
            newPasswordTextField.text == "" ||
            confirmNewPasswordTextField.text == "") {
            print("請確認必填欄位皆已輸入")
            Alert.showAlertWith(title: "",
                                message: translate(.Please_make_sure_all_required_fields_are_entered),
                                vc: self,
                                confirmTitle: translate(.Confirm))
        } else {
            print("必填欄位皆已填寫，但網址、備註可為空值")
            // 按下儲存按鈕後要做的事 ...
            let result = changePassword(id: UserPreferences.shared.userID, originPassword: originPasswordTextField.text!, newPassword: newPasswordTextField.text!)
            if (result == true) {
                Alert.showToastWith(message: translate(.Change_Password_Succeed),
                                    vc: self,
                                    during: .long, dismiss:  {
                    self.popToRootViewController()
                })
            }
        }
    }
    
    @IBAction func textFieldDidChanged(_ sender: UITextField) {
        guard let textFieldText = sender.text else {
            return
        }
        switch sender {
        case originPasswordTextField:
            DispatchQueue.main.async {
                self.originPasswordCountLabel.text = "\(textFieldText.count)/50"
            }
        case newPasswordTextField:
            DispatchQueue.main.async {
                self.newPasswordCountLabel.text = "\(textFieldText.count)/50"
            }
        case confirmNewPasswordTextField:
            DispatchQueue.main.async {
                self.confirmNewPasswordCountLabel.text = "\(textFieldText.count)/50"
            }
        default:
            break
        }
    }
}
// MARK: - NavigationBarViewDelegate

extension ChangePasswordViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        backButtonAction()
    }
    
    func btnRightClicked(index: Int) {
        saveButtonAction()
    }
}
// MARK: - UITextFieldDelegate

extension ChangePasswordViewController: UITextFieldDelegate {
    
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
        case originPasswordTextField:
            return count <= 50
        case newPasswordTextField:
            return count <= 50
        case confirmNewPasswordTextField:
            return count <= 50
        default:
            return true
        }
    }
}
