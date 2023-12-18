//
//  FirebaseRealtimeDatabase.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/9/23
//

import Foundation
import FirebaseDatabase

class FirebaseRealtimeDatabase: NSObject {
    
    static let shared = FirebaseRealtimeDatabase()
    
    var databaseRef: DatabaseReference!
    
    /// 將資料上傳到 Firebase Realtime Database
    /// - Parameters:
    ///   - domain: String，從 Chrome Extension 的 QrCode 取得的 domain
    ///   - browserUid: String，從 Chrome Extension 的 QrCode 取得的 browserUid
    ///   - data: 要上傳到 Firebase Realtime Database 的帳號密碼 (明文)
    ///   - finish: 上傳完成後要做的事
    func add(domain: String, browserUid: String, data: RealtimeDatabaseUpload, finish: @escaping () -> Void) {
        databaseRef = Database.database().reference().child("device")
        
        let domain = sourceURLPreProcess(source: domain)
        let child = browserUid + "-" + domain
        let uploadData = uploadDataAES256EncryptHexString(data: data, browserUid: browserUid)
        #if DEBUG
        print("uploadData：", uploadData)
        #endif
        
        let data: [String : Any] = [
            "data" : uploadData,
            "timestamp" : ServerValue.timestamp()
        ]
        
        self.databaseRef.child(child).setValue(data)
        
        databaseRef.child(child).observe(.childAdded) { snapshot in
            finish()
        }
    }
    
    /// 將 URL 上不需要的字進行預處理去除
    /// - Parameter url: 網站的 URL
    /// - Returns: 處理完的 URL
    private func sourceURLPreProcess(source url: String) -> String {
        if url.contains("http://") ||
            url.contains("https://") ||
            url.contains(".") ||
            url.contains("#") ||
            url.contains("$") ||
            url.contains("[") ||
            url.contains("]") {
            let results = url
                .replacingOccurrences(of: "http://", with: "")
                .replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: ".", with: "-")
                .replacingOccurrences(of: "#", with: "-")
                .replacingOccurrences(of: "$", with: "-")
                .replacingOccurrences(of: "[", with: "-")
                .replacingOccurrences(of: "]", with: "-")
            return results
        } else {
            return url
        }
    }
    
    /// 將要上傳 Firebase Realtime Database 的帳號密碼進行 AES256 加密並轉成 HexString
    /// - Parameters:
    ///   -  data: E，struct RealtimeDatabaseUpload， 需繼承 Encodable Protocol
    ///   - browserUid: String，從 Chrome Extension 的 QrCode 取得的 browserUid
    /// - Returns: 加密過後的 JSON Object to HexString
    private func uploadDataAES256EncryptHexString<E: Encodable>(data: E, browserUid: String) -> String? {
        let cryptoManager = CryptoManager()
        
        guard let jsonObject = cryptoManager.classToJsonData(input: data) else {
            return nil
        }
        
        let jsonObjectToString = String(data: jsonObject, encoding: .utf8)
        
        guard let jsonObjectToStringToData = jsonObjectToString?.data(using: .utf8) else {
            return nil
        }
        
        let str = browserUid.split(separator: "-")
        let privateKey = String(str[2] + str[4])
        
        guard let encryptedJsonObject = cryptoManager.aes256EncryptedWithoutIV(clearText: jsonObjectToStringToData,
                                                                               privateKey: privateKey) else {
            return nil
        }
        
        guard let decryptedJsonObject = cryptoManager.aes256DecryptedWithoutIV(cipherText: encryptedJsonObject,
                                                                               privateKey: privateKey) else {
            return nil
        }
        
        #if DEBUG
        print("decrypted：", String(data: decryptedJsonObject, encoding: .utf8)!)
        #endif
        
        let cipherTextToHexString = encryptedJsonObject.toHexString().uppercased()
        return cipherTextToHexString
    }
}
