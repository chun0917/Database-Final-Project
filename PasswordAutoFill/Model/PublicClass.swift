//
//  PublicClass.swift
//  PasswordAutoFill
//
//  Created by 呂淳昇 on 2022/8/1.
//

class SingletonPatternOfURLText {
    
    static let shared = SingletonPatternOfURLText()
    
    var autofillURLText = String()
}
