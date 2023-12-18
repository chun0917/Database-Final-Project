//
//  NotesModel.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/3.
//

import Foundation

struct NotesModel: Codable {
    
    /// 每筆資料的唯一識別碼
    var id = UUID().uuidString
    
    /// 標題
    var title: String
    
    /// 備註
    var note: String
}
