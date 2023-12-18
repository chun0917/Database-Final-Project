//
//  SettingsMainTableViewCell.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/3.
//

import UIKit

class SettingsMainTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightSwitch: UISwitch!
    
    // MARK: - Variables
    
    static let identifier = "SettingsMainTableViewCell"
    
    // UISwitch 狀態改變後，會呼叫的 Closure
    // 實際執行內容由使用 Cell 的頁面定義
    var onSwitchTapped: ((UISwitch) -> ())? = nil
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - UI Initial Setup
    
    /// 設定頁面的 UI 樣式設定
    /// - Parameters:
    ///   - imageName: [enum SFSymbols](x-source-tag://SFSymbols)，icon 圖片名稱
    ///   - title: 設定選項的標題
    ///   - switchState: UISwitch 的狀態
    ///   - isHidden: 是否顯示 UISwitch
    func setupUI(imageName: SFSymbols,
                 title: String,
                 switchState: Bool,
                 switchIsHidden: Bool) {
        leftIconImageView.image = UIImage(icon: imageName)
        titleLabel.text = title
        setupSwitch(switchState: switchState, isHidden: switchIsHidden, switchTag: 0)
    }
    
    /// 設定 `生物辨識鎖定 Switch` 的 Switch 樣式
    /// - Parameters:
    ///   - switchState: Switch 的狀態
    ///   - isHidden: 是否顯示 Switch
    ///   - switchTag: Switch 的 tag
    private func setupSwitch(switchState: Bool, isHidden: Bool, switchTag: Int) {
        rightSwitch.isOn = switchState
        rightSwitch.isHidden = isHidden
        rightSwitch.tag = switchTag
    }
    
    // MARK: - IBAction
    
    @IBAction func rightSwitchPressed(_ sender: UISwitch) {
        onSwitchTapped?(sender)
    }
}
