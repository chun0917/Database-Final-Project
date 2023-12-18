//
//  BackupOperationTableViewCell.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/21.
//

import UIKit

class BackupOperationTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var backupLabel: UILabel!
    @IBOutlet weak var autoBackupStatusLabel: UILabel!
    
    // MARK: - Variables
    
    static let identifier = "BackupOperationTableViewCell"
    
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
    
    func setInit(backupTitle: String, automaticBackupIntervalTitle: String, statusIsHidden: Bool) {
        backupLabel.text = backupTitle
        autoBackupStatusLabel.isHidden = statusIsHidden
        if statusIsHidden {
            autoBackupStatusLabel.text = ""
        } else {
            autoBackupStatusLabel.text = automaticBackupIntervalTitle
        }
    }
}
