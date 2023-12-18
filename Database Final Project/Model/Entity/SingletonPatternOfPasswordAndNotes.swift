//
//  SingletonPatternOfPasswordAndNotes.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/22.
//

import Foundation

class SingletonPatternOfPasswordAndNotes {
    
    static let shared = SingletonPatternOfPasswordAndNotes()

    var id: String = ""
    
    var title: String = ""    // 標題
    
    var account: String = ""  // 帳號
    
    var password: String = "" // 密碼
    
    var url: String = ""      // 網址
    
    var note: String = ""     // 註記
    
    var passwordArray: Array<PasswordModel> = []
    
    var noteArray: Array<NotesModel> = []
}
