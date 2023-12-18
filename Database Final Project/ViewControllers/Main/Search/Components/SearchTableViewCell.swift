//
//  SearchTableViewCell.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/30.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var searchCellImageView: UIImageView!
    @IBOutlet weak var searchTitleLabel: UILabel!
    @IBOutlet weak var searchAccountLabel: UILabel!
    
    // MARK: - Variables
    
    static let identifier = "SearchTableViewCell"
    
    var index = 0
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - UI Settings
    
    /// 設定 UI
    /// - Parameters:
    ///   - root : 判斷是哪個畫面觸發的
    ///   - title: 搜尋的標題
    ///   - account: 搜尋的帳號／備註
    func setInit(root: SearchViewController.Root, title: String, account: String, index: Int) {
        switch root {
        case .password:
            searchCellImageView.image = UIImage(icon: .key)
        case .notes:
            searchCellImageView.image = UIImage(icon: .notes)
        }
        searchTitleLabel.text = title
        searchAccountLabel.text = account
        self.index = index
    }
}
