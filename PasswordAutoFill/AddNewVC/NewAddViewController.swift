//
//  AddNewVC.swift
//  PasswordAutoFill
//
//  Created by 呂淳昇 on 2022/10/13.
//

import UIKit
import AuthenticationServices

class NewAddViewController: ASCredentialProviderViewController {
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet var requiredLabels: [UILabel]!
    @IBOutlet weak var titleTextField: CustomTextField!
    @IBOutlet weak var accountTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomPasswordLockTextField!
    @IBOutlet weak var getNewPasswordButton: UIButton!
    @IBOutlet weak var urlTextField: CustomTextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var showAdvancedSettingsButton: UIButton!
    @IBOutlet weak var hideAdvancedSettingsButton: UIButton!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var accountCountLabel: UILabel!
    @IBOutlet weak var passwordCountLabel: UILabel!
    @IBOutlet weak var urlCountLabel: UILabel!
    @IBOutlet weak var notesCountLabel: UILabel!
    
    // MARK: - Variables
    
    var receivePassword: String = "" // 從安全密碼產生器傳過來的密碼
    
    // 宣告這個畫面會遵循 NewAddAccountVCCellItemProtocol
    // 並請委任目標（delegate）去處理 NewAddAccountVCCellItemProtocol 的事件
    var delegate: NewAddAccountVCCellItemProtocol!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - UI Settings
    
    /// 設定 UI
    func setupUI() {
        
        // NavigationBar
        setupBarButtonItem()
        
        // 設定 TextField 樣式
        setupTextFields()
        
        // 設定 noteTextView 樣式
        setupTextViewMode()
        
        setupCountLabel()
        
        // 設定 `顯示進階設定` 跟 `隱藏進階設定` 的按鈕樣式
        showAdvancedSettingsButton.setTitle(translate(.Show_Advanced_Settings), for: .normal)
        hideAdvancedSettingsButton.setTitle(translate(.Hide_Advanced_Settings), for: .normal)
        
        // 設定`產生新密碼` 底線樣式
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font : UIFont.systemFont(ofSize: 20),             // 文字大小、字體樣式
            .foregroundColor : #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) ,                            // 文字顏色
            .underlineStyle : NSUnderlineStyle.single.rawValue // .single 單條底線 .double .thick 單條粗底線
        ]
        let getNewPasswordAttribute = NSMutableAttributedString(
            string: translate(.Get_New_Password),
            attributes: textAttributes
        )
        getNewPasswordButton.setAttributedTitle(getNewPasswordAttribute, for: .normal)
        
        requiredLabels[0].text = translate(.Required)
        requiredLabels[1].text = translate(.Required)
        requiredLabels[2].text = translate(.Required)
    }
    
    private func setupBarButtonItem() {
        cancelBarButtonItem.title = translate(.Cancel)
        saveBarButtonItem.title = translate(.Extension_Save)
    }
    
    /// 設定字數統計 Label 樣式
    private func setupCountLabel() {
        titleCountLabel.text = "\(0)/35"
        accountCountLabel.text = "\(0)/100"
        passwordCountLabel.text = "\(0)/50"
        urlCountLabel.text = "\(urlTextField.text!.count)/100"
        notesCountLabel.text = "\(0)/100"
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        // 標題
        titleTextField.placeholder = translate(.Title)
        titleTextField.delegate = self
        
        // 帳號
        accountTextField.placeholder = translate(.Account)
        accountTextField.delegate = self
        
        // 密碼
        passwordTextField.placeholder = translate(.Password)
        passwordTextField.delegate = self
        
        // 網址
        urlTextField.placeholder = translate(.URL)
        urlTextField.text = SingletonPatternOfURLText.shared.autofillURLText
        urlTextField.delegate = self
    }
    
    /// 設定 noteTextView 樣式
    private func setupTextViewMode() {
        noteTextView.layer.borderColor = UIColor.gray.cgColor
        noteTextView.layer.borderWidth = 2
        noteTextView.layer.cornerRadius = noteTextView.bounds.height/10
        noteTextView.showsVerticalScrollIndicator = true // 垂直滾動指示器
        noteTextView.showsHorizontalScrollIndicator = false // 水平滾動指示器
        noteTextView.delegate = self
    }
    
    // MARK: - IBAction
    
    @IBAction func hideOrShowTextFields(_ sender: UIButton) {
        switch sender.tag {
        case 0: // 按下顯示進階設定按鈕
            showView.isHidden = true
            hideView.isHidden = false
        case 1: // 按下隱藏進階設定按鈕
            showView.isHidden = false
            hideView.isHidden = true
        default:
            break
        }
    }
    
    @IBAction func getNewPasswordBtnClicked(sender: UIButton) {
        let nextVC = NewGenerateRandomPasswordViewController()
        nextVC.delegate = self
        nextVC.isModalInPresentation = true
        self.present(nextVC, animated: false)
    }
    
    @IBAction func textFieldDidChanged(_ sender: UITextField) {
        guard let textFieldText = sender.text else {
            return
        }
        switch sender {
        case titleTextField:
            DispatchQueue.main.async {
                self.titleCountLabel.text = "\(textFieldText.count)/35"
            }
        case accountTextField:
            DispatchQueue.main.async {
                self.accountCountLabel.text = "\(textFieldText.count)/100"
            }
        case passwordTextField:
            DispatchQueue.main.async {
                self.passwordCountLabel.text = "\(textFieldText.count)/50"
            }
        case urlTextField:
            DispatchQueue.main.async {
                self.urlCountLabel.text = "\(textFieldText.count)/100"
            }
        default:
            break
        }
    }
    
    /// 回上一頁
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        if (titleTextField.text == "" &&
            accountTextField.text == "" &&
            passwordTextField.text == "" &&
            urlTextField.text == "" &&
            noteTextView.text == "") {
            //print("輸入框為空值")
            self.dismiss(animated: true, completion: nil)
        } else {
            //print("輸入框有值")
            Alert.showAlertWith(title: translate(.Cancel_Add),
                                message: translate(.The_currently_entered_data_has_not_been_saved_Do_you_want_to_leave_this_screen),
                                vc: self,
                                confirmTitle: translate(.Confirm),
                                cancelTitle: translate(.Cancel)) {
                self.dismiss(animated: true, completion: nil)
            } cancel: {
                //
            }
        }
    }
    
    /// 儲存資料
    @IBAction func saveBtnClicked(_ sender: UIBarButtonItem) {
        if (titleTextField.text != "" &&
            accountTextField.text != "" &&
            passwordTextField.text != "") {
            // 新增密碼
            print("account：", accountTextField.text!)
            print("password：", passwordTextField.text!)
            print("url：", SingletonPatternOfURLText.shared.autofillURLText)
            
            let pm = PasswordModel(id: UUID().uuidString,
                                   title: titleTextField.text!,
                                   account: accountTextField.text!,
                                   password: passwordTextField.text!,
                                   url: SingletonPatternOfURLText.shared.autofillURLText,
                                   note: noteTextView.text ?? "")
            let cryptoManager = CryptoManager()
            
            /// Step0：原始資料
            guard let pmData = cryptoManager.classToJsonData(input: pm) else { return }
            print(String(data: pmData, encoding: .utf8)!)
            
            /// Step1：privateKey
            let privateKey = UserPreferences.shared.privateKeyForDatabase
            /// Step2：privateKey 經過 SHA256 Hash 得出 preIV
            let preIV = cryptoManager.generatePreIV(privateKey: privateKey)
            /// Step3：preIV 取前 16Bytes 得出 IV
            let iv = cryptoManager.generateIV(preIV: preIV)
            let ivToString = iv.toHexString()
            /// Step4：IV + privateKey + 明文 (原始資料) 經過 AES256 加密得出密文
            
            guard let pmOriginalData = String(data: pmData, encoding: .utf8)!.data(using: .utf8) else { return }
            
            guard let encrypted_pmData = cryptoManager.aes256Encrypted(clearText: pmOriginalData,
                                                                       privateKey: privateKey,
                                                                       iv: ivToString) else {
                return
            }
            
            let combined = cryptoManager.combinedCipherTextAndPreIV(cipherText: encrypted_pmData,
                                                                    preIV: preIV)
            
            LocalDatabase.shared.insert(id: pm.id,userID: UserPreferences.shared.userID, cipherText: combined, table: .password)
            
            delegate.reloadData()
            self.dismiss(animated: true, completion: nil)
        } else {
            Alert.showAlertWith(title: "",
                                message: translate(.Please_make_sure_all_required_fields_are_entered),
                                vc: self,
                                confirmTitle: translate(.Confirm))
            print("有空值")
        }
    }
}

// MARK: - NewGenerateRandomPasswordDelegate

extension NewAddViewController: NewGenerateRandomPasswordDelegate {
    
    func postNewGeneratePassword(newPassword: String) {
        DispatchQueue.main.async {
            self.receivePassword = newPassword
            self.passwordTextField.text = self.receivePassword
            self.passwordCountLabel.text = "\(newPassword.count)/50"
        }
    }
}

extension NewAddViewController: UITextFieldDelegate {
    
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
        case titleTextField:
            return count <= 35
        case accountTextField:
            return count <= 100
        case passwordTextField:
            return count <= 50
        case urlTextField:
            return count <= 100
        default:
            return true
        }
    }
}

// MARK: - UITextViewDelegate

extension NewAddViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        guard let textViewText = textView.text,
              let rangeOfTextToReplace = Range(range, in: textViewText) else {
            return false
        }
        
        let substringToReplace = textViewText[rangeOfTextToReplace]
        let count = textViewText.count - substringToReplace.count + text.count
        
        return count <= 100
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.notesCountLabel.text = "\(textView.text.count)/100"
        }
    }
}

// MARK: - NewAddAccountVCCellItemProtocol

protocol NewAddAccountVCCellItemProtocol {
    
    func reloadData()
}
