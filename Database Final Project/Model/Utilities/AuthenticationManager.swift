//
//  AuthenticationManager.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/6/30.
//

import Foundation
import AuthenticationServices

class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    /// 偵測在 `設定 -> 密碼 -> 自動帶入密碼` 內，是否勾選 App
    func getAutoFillStatusInSettings(finish: @escaping (Bool) -> Void) {
        Task {
            let state = await ASCredentialIdentityStore.shared.state()
            finish(state.isEnabled)
        }
    }
}
