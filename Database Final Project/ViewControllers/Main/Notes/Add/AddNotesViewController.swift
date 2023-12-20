//
//  AddNotesViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/15.
//

import UIKit
import IQKeyboardManagerSwift

class AddNotesViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet var requiredLabels: [UILabel]!
    @IBOutlet weak var titleTextField: CustomTextField!
    @IBOutlet weak var noteTextView: IQTextView!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var notesCountLabel: UILabel!
    
    // MARK: - Variables
    
    weak var showFirstAddAlertDelegate: ShowFirstAddAlertDelegate?

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupNavigationBarView()
        setupTextFields()
        setupCountLabel()
        setupTextView()
        setupRequiredLabels()
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.Add),
                               displayMode: .leftRight,
                               btnIcon2: .save)
    }
    
    /// 設定字數統計 Label 樣式
    private func setupCountLabel() {
        titleCountLabel.text = "\(0)/35"
        notesCountLabel.text = "\(0)/100"
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        titleTextField.placeholder = translate(.Title)
        titleTextField.delegate = self
    }
    
    /// 設定 noteTextView 樣式
    private func setupTextView() {
        noteTextView.layer.borderColor = UIColor.gray.cgColor
        noteTextView.layer.borderWidth = 2
        noteTextView.layer.cornerRadius = noteTextView.bounds.height/10
        noteTextView.placeholderTextColor = #colorLiteral(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        noteTextView.showsVerticalScrollIndicator = true // 垂直滾動指示器
        noteTextView.showsHorizontalScrollIndicator = false // 水平滾動指示器
        noteTextView.placeholder = translate(.Note)
        noteTextView.delegate = self
    }
    
    /// 設定`必填的Label`的多國語言
    private func setupRequiredLabels() {
        requiredLabels[0].text = translate(.Required)
        requiredLabels[1].text = translate(.Required)
    }
    
    @objc func backButtonAction() {
        if (titleTextField.text == "" && noteTextView.text == "") {
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
        if (titleTextField.text == "" || noteTextView.text == "") {
            print("請確認必填欄位皆已輸入")
            Alert.showAlertWith(title: "",
                                message: translate(.Please_make_sure_all_required_fields_are_entered),
                                vc: self,
                                confirmTitle: translate(.Confirm),
                                confirm: nil)
        } else {
            print("必填欄位皆已填寫，但網址、備註可為空值")
            // 按下儲存按鈕後要做的事...
                Alert.showToastWith(message: translate(.Save_Notes_Succeed),
                                    vc: self,
                                    during: .long) { [unowned self] in
                    // 新增記事
                    let nm = NotesModel(id: UUID().uuidString,
                                        title: titleTextField.text!,
                                        note: noteTextView.text!)
                    let cryptoManager = CryptoManager()
                    
                    /// Step0：原始資料
                    guard let nmData = cryptoManager.classToJsonData(input: nm) else { return }
                    print(String(data: nmData, encoding: .utf8)!)

                    /// Step1：privateKey
                    let privateKey = UserPreferences.shared.privateKeyForDatabase
                    /// Step2：privateKey 經過 SHA256 Hash 得出 preIV
                    let preIV = cryptoManager.generatePreIV(privateKey: privateKey)
                    /// Step3：preIV 取前 16Bytes 得出 IV
                    let iv = cryptoManager.generateIV(preIV: preIV)
                    let ivToString = iv.toHexString()
                    /// Step4：IV + privateKey + 明文 (原始資料) 經過 AES256 加密得出密文
                    
                    guard let nmOriginalData = String(data: nmData, encoding: .utf8)!.data(using: .utf8) else { return }
                    
                    guard let encrypted_nmData = cryptoManager.aes256Encrypted(clearText: nmOriginalData,
                                                                               privateKey: privateKey,
                                                                               iv: ivToString) else {
                        return
                    }
                    
                    let combined = cryptoManager.combinedCipherTextAndPreIV(cipherText: encrypted_nmData,
                                                                            preIV: preIV)
                            
                    LocalDatabase.shared.insert(id: nm.id, userID: UserPreferences.shared.userID, cipherText: combined, table: .note)
                    
                } dismiss: {
                    if UserPreferences.shared.isFirstAddPasswordOrNotes == false {
                        self.showFirstAddAlertDelegate?.showAlert()
                    }
                    self.popToRootViewController()
                }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func textFieldDidChanged(_ sender: UITextField) {
        guard let textFieldText = sender.text else {
            return
        }
        DispatchQueue.main.async {
            self.titleCountLabel.text = "\(textFieldText.count)/35"
        }
    }
}

// MARK: - NavigationBarViewDelegate

extension AddNotesViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        backButtonAction()
    }
    
    func btnRightClicked(index: Int) {
        saveButtonAction()
    }
}

// MARK: - UITextFieldDelegate

extension AddNotesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count

        return count <= 35
    }
}

// MARK: - UITextViewDelegate

extension AddNotesViewController: UITextViewDelegate {
    
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

protocol ShowFirstAddAlertDelegate: NSObjectProtocol {
    
    func showAlert()
}
