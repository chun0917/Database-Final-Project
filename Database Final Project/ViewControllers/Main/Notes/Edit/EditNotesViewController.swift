//
//  AddNotesViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/15.
//

import UIKit
import IQKeyboardManagerSwift

class EditNotesViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet var requiredLabels: [UILabel]!
    @IBOutlet weak var titleTextField: CustomTextField!
    @IBOutlet weak var noteTextView: IQTextView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var notesCountLabel: UILabel!
    
    // MARK: - Variables
    
    var tmpTitle = SingletonPatternOfPasswordAndNotes.shared.title
    var tmpNote = SingletonPatternOfPasswordAndNotes.shared.note
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        // 若使用者沒編輯但按下儲存的按鈕
        if tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title &&
            tmpNote == SingletonPatternOfPasswordAndNotes.shared.note {
            setupSaveButtonType(buttonIsEnabled: false, buttonAlpha: 0.5)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SingletonPatternOfPasswordAndNotes.shared.title = ""
        SingletonPatternOfPasswordAndNotes.shared.account = ""
        SingletonPatternOfPasswordAndNotes.shared.password = ""
        SingletonPatternOfPasswordAndNotes.shared.url = ""
        SingletonPatternOfPasswordAndNotes.shared.note = ""
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupNavigationBarView() // 設定 NavigationBar 樣式
        setupTextFields() // TextField 樣式
        setupTextView() // noteTextView 樣式
        setupRequiredLabels() // `必填的Label`的多國語言
        setupCopyButton() // copyButton 樣式
        setInit(title: SingletonPatternOfPasswordAndNotes.shared.title,
                note: SingletonPatternOfPasswordAndNotes.shared.note)
        setupCountLabel()
    }
    
    /// 設定進`編輯畫面`的值
    func setInit(title: String, note: String) {
        // setup text
        titleTextField.text = SingletonPatternOfPasswordAndNotes.shared.title
        noteTextView.text = SingletonPatternOfPasswordAndNotes.shared.note.isEmpty ? translate(.Note) : SingletonPatternOfPasswordAndNotes.shared.note
        
        // setup textColor to be like placeholder
        titleTextField.textColor = .placeholderText
        noteTextView.textColor = .placeholderText
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.Edit),
                               displayMode: .leftRight,
                               btnIcon2: .save)
    }
    
    /// 設定字數統計 Label 樣式
    private func setupCountLabel() {
        titleCountLabel.text = "\(titleTextField.text!.count)/35"
        notesCountLabel.text = "\(noteTextView.text.count)/100"
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        titleTextField.delegate = self
    }
    
    /// 設定 noteTextView 樣式
    private func setupTextView() {
        noteTextView.delegate = self
        noteTextView.layer.borderColor = UIColor.gray.cgColor
        noteTextView.layer.borderWidth = 2
        noteTextView.layer.cornerRadius = noteTextView.bounds.height/15
        noteTextView.showsVerticalScrollIndicator = true // 垂直滾動指示器
        noteTextView.showsHorizontalScrollIndicator = false // 水平滾動指示器
    }
    
    /// 設定`必填的Label`的多國語言
    private func setupRequiredLabels() {
        requiredLabels[0].text = translate(.Required)
        requiredLabels[1].text = translate(.Required)
    }
    
    /// 設定 rightBarButtonItem 的儲存按鈕狀態
    private func setupSaveButtonType(buttonIsEnabled: Bool, buttonAlpha: CGFloat) {
        vNavigationBar.btnRight2.isEnabled = buttonIsEnabled
        vNavigationBar.btnRight2.tintColor = UIColor.white.withAlphaComponent(buttonAlpha)
    }
    
    /// 設定 copyButton 樣式
    private func setupCopyButton() {
        copyButton.setTitle("", for: .normal)
        copyButton.setImage(UIImage(icon: .copy), for: .normal)
        copyButton.tintColor = .black
    }
    
    // MARK: - Right NavigationBarItems Function
    
    /// 按下退回按鈕後要做的事 ...
    private func backButtonAction() {
        if tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title &&
            tmpNote == SingletonPatternOfPasswordAndNotes.shared.note {
            print("輸入框為空值")
            self.popViewController()
        } else {
            print("輸入框有值")
            Alert.showAlertWith(title: translate(.Cancel_Edit),
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
    
    /// 按下儲存按鈕後要做的事 ...
    private func saveButtonAction() {
        if (titleTextField.text == "") || (noteTextView.text == "") {
            print("請確認必填欄位皆已輸入")
            Alert.showAlertWith(title: "",
                                message: translate(.Please_make_sure_all_required_fields_are_entered),
                                vc: self,
                                confirmTitle: translate(.Confirm),
                                confirm: nil)
        } else {
            print("必填欄位皆已填寫，但網址、備註可為空值")
            // 按下儲存按鈕後要做的事...
            Alert.showToastWith(message: translate(.Edit_Notes_Succeed),
                                vc: self, during: .long) {
                // 編輯記事
                let nm = NotesModel(id: SingletonPatternOfPasswordAndNotes.shared.id,
                                    title: self.titleTextField.text!,
                                    note: self.noteTextView.text!)
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
                
                LocalDatabase.shared.update(id: nm.id, userID: UserPreferences.shared.userID, cipherText: combined, table: .note)
            } dismiss: {
                self.popToRootViewController()
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func copyNotes(_ sender: UIButton) {
        // 複製註記
        Alert.showAlertWith(title: translate(.Copy_Succeed),
                            message: translate(.Information_has_been_copied_to_the_scrapbook),
                            vc: self,
                            confirmTitle: translate(.Confirm)) {
            let board = UIPasteboard.general
            board.string = self.noteTextView.text
        }
    }
    
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

extension EditNotesViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        backButtonAction()
    }
    
    func btnRightClicked(index: Int) {
        saveButtonAction()
    }
}

// MARK: - UITextFieldDelegate

extension EditNotesViewController: UITextFieldDelegate {
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleTextField.text = tmpTitle
        titleTextField.textColor = .black
        setupSaveButtonType(buttonIsEnabled: true, buttonAlpha: 1)
    }
    
    // 標題 TextField 輸入完後，按空白處會執行的事
    func textFieldDidEndEditing(_ textField: UITextField) {
        if titleTextField.text == SingletonPatternOfPasswordAndNotes.shared.title {
            titleTextField.textColor = .placeholderText
        }
        tmpTitle = titleTextField.text!
        
        // 若最後變更完值依然跟單例的值相同，rightBarButtonItem 的儲存鍵就不能按
        if (tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title) &&
            (tmpNote == SingletonPatternOfPasswordAndNotes.shared.note) {
            setupSaveButtonType(buttonIsEnabled: false, buttonAlpha: 0.5)
        }
    }
}

// MARK: - UITextViewDelegate

extension EditNotesViewController: UITextViewDelegate {
    
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteTextView.text = tmpNote
        noteTextView.textColor = .black
        setupSaveButtonType(buttonIsEnabled: true, buttonAlpha: 1)
    }
    
    // 備註 TextView 輸入完後，按空白處會執行的事
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextView.text == SingletonPatternOfPasswordAndNotes.shared.note {
            noteTextView.textColor = .placeholderText
        }
        tmpNote = noteTextView.text!
        
        // 若最後變更完值依然跟單例的值相同，rightBarButtonItem 的儲存鍵就不能按
        if (tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title) &&
            (tmpNote == SingletonPatternOfPasswordAndNotes.shared.note) {
            setupSaveButtonType(buttonIsEnabled: false, buttonAlpha: 0.5)
        }
    }
}
