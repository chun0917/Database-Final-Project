//
//  PasswordModel.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/1.
//

import Foundation

struct PasswordModel: Codable {
    
    /// 每筆資料的唯一識別碼
    var id = UUID().uuidString
    
    /// 標題
    var title: String
    
    /// 帳號名稱
    var account: String
    
    /// 密碼
    var password: String
    
    /// 網址
    var url: String
    
    /// 備註
    var note: String
}
