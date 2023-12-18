//
//  CryptoManager.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/9/2.
//

import Foundation
import CryptoSwift

/// CryptoManager，用來處理資料加解密
///
/// 使用範例如下
///
///     let cryptoManager = CryptoManager()
///
///     // Step0：原始資料
///     let originalData = "UserPassword1!"
///
///     guard let inputData = originalData.data(using: .utf8) else {
///         return
///     }
///
///     // let pm = PasswordModel(id: UUID().uuidString,
///                               title: "5大唱片",
///                               account: "zaqxsw0219",
///                               password: "zaqxsw0219",
///                               url: "https://www.5music.com.tw/member_login.asp",
///                               note: "5大唱片")
///
///     // let nm = NotesModel(id: UUID().uuidString, title: "5大唱片完美", note: "5大唱片是我後花園")
///
///     // let am = ApexModel(id: UUID().uuidString, xlh: "fneicneic")
///
///     // guard let inputData = cryptoManager.classToJsonData(input: am) else { return }
///
///     print("inputData to String：", String(data: inputData, encoding: .utf8))
///
///     // Step1：privateKey
///     let privateKey = "12345678901234561234567890123456"
///
///     // Step2：privateKey 經過 SHA256 Hash 得出 preIV
///     let preIV = cryptoManager.generatePreIV(privateKey: privateKey)
///     print("preIV：", preIV.toHexString())
///
///     // Step3：preIV 取前 16Bytes 得出 IV
///     let iv = cryptoManager.generateIV(preIV: preIV)
///     print("iv：", iv.toHexString())
///     let ivToString = iv.toHexString()
///
///     // Step4：IV + privateKey + 明文 (原始資料) 經過 AES256 加密得出密文
///     guard let encryptedData = cryptoManager.aes256Encrypted(clearText: inputData, privateKey: privateKey, iv: ivToString) else {
///         return
///     }
///     print("encryptedData to String：", encryptedData.toHexString())
///
///     // 使用 privateKey + IV 對密文進行解密
///     guard let decryptedData = cryptoManager.aes256Decrypted(cipherText: encryptedData, privateKey: privateKey, iv: ivToString) else {
///         return
///     }
///     print("decryptedData to String：", String(data: decryptedData, encoding: .utf8))
///
///     // 將「密文.toHexString」與「preIV.toHexString」透過 `+` 來串接
///     let combinedCipherTextAndPreIVWithHexString = cryptoManager.combinedCipherTextAndPreIV(cipherText: encryptedData, preIV: preIV)
///     print("combinedCipherTextAndPreIVWithHexString：", combinedCipherTextAndPreIVWithHexString)
///
///     // 將「密文.toHexString+preIV.toHexString」拆解成「密文.toHexString」跟「preIV.toHexString」
///     let splitResults = cryptoManager.splitCipherTextAndPreIV(combinedString: combinedCipherTextAndPreIVWithHexString)
///     print("cipherText toHexString：", splitResults.cipherText)
///     print("preIV toHexString：", splitResults.preIV)
///
/// 輸出結果如下
///
///     // Step0：原始資料
///     inputData to String： Optional("UserPassword1!")
///
///     // Step2：privateKey 經過 SHA256 Hash 得出 preIV
///     preIV： 9b2a00558d1a255513f54ca81e787380c6c4be490f0be2288161e59f77d3df8e
///
///     // Step3：preIV 轉成 [UInt8]
///     allPreIV： [155, 42, 0, 85, 141, 26, 37, 85, 19, 245, 76, 168, 30, 120, 115, 128, 198, 196, 190, 73, 15, 11, 226, 40, 129, 97, 229, 159, 119, 211, 223, 142]
///
///     // Step3：preIV 取前 16Bytes 得出 IV
///     ivArray： [155, 42, 0, 85, 141, 26, 37, 85]
///     iv： 9b2a00558d1a2555
///
///     // Step4：IV + privateKey + 明文 (原始資料) 經過 AES256 加密得出密文
///     encryptedData to String： 67711e6a8c78b87bee5438534debbafb
///
///     // 使用 privateKey + IV 對密文進行解密
///     decryptedData to String： Optional("UserPassword1!")
///
///     // 將「密文.toHexString」與「preIV.toHexString」透過 `+` 來串接
///     combinedCipherTextAndPreIVWithHexString： 1c9880c45a0a0b2f42da2ef3ed1583c2+f6d527e6d01865481134f29788be2afe7fc3c702e1a55d7ceafac5f35199e8dc
///
///     // 將「密文.toHexString+preIV.toHexString」拆解成「密文.toHexString」跟「preIV.toHexString」
///     cipherText toHexString： 1c9880c45a0a0b2f42da2ef3ed1583c2
///     preIV toHexString： f6d527e6d01865481134f29788be2afe7fc3c702e1a55d7ceafac5f35199e8dc
///
class CryptoManager {
    
    /// 產生 preIV
    /// - Parameters:
    ///   - privateKey: String 或是 Data 型別
    /// - Returns: privateKey 經過 SHA256 Hash 過後的 preIV
    func generatePreIV<T>(privateKey data: T) -> Data where T: Hashable {
        var preIV = Data()
        if T.self == String.self {
            preIV = sha256HashEncrypt(privateKey: (data as! String).data(using: .utf8)!)
        } else if T.self == Data.self {
            preIV = sha256HashEncrypt(privateKey: data as! Data)
        }
        return preIV
    }
    
    /// 產生 IV
    /// - Parameter data: 透過 func generatePreIV<T>(privateKey data: T) -> Data 所產生的 preIV
    /// - Returns: 從 preIV 取出前 16 Bytes 當作 IV
    func generateIV(preIV data: Data) -> Data {
        let allPreIVBytes = [UInt8](data)
        let blockSize = 16
        var ivBytesArray: [UInt8] = []
        #if DEBUG
        print("allPreIV：", allPreIVBytes)
        #endif
        for i in 0 ..< blockSize / 2 {
            ivBytesArray.append(allPreIVBytes[i])
        }
        #if DEBUG
        print("ivArray：", ivBytesArray)
        #endif
        let ivData = Data(ivBytesArray)
        return ivData
    }
    
    /// 透過 privateKey + IV 將原始資料進行 AES256 加密
    /// - Parameters:
    ///   - data: 明文 (要經過 AES256 加密的原始資料)
    ///   - key: privateKey
    ///   - iv: 透過 func generateIV(preIV data: Data) -> Data 所產生的 IV
    /// - Returns: 產生經過 AES256 加密過後的密文
    func aes256Encrypted(clearText data: Data, privateKey key: String, iv: String) -> Data? {
        return aes256Encrypt(clearText: data, privateKey: key, iv: iv)
    }
    
    /// 將要上傳 Firebase Realtime Database 的資料透過 AES256 進行加密
    /// - Parameters:
    ///   - data: 明文 (要經過 AES256 加密的帳號密碼)
    ///   - key: BrowserUid 取第三及第五段組合作為 key
    /// - Returns: 產生經過 AES256 加密過後的密文
    func aes256EncryptedWithoutIV(clearText data: Data, privateKey key: String) -> Data? {
        let privateKey = Array(key.utf8)
        return aes256EncryptWithoutIV(clearText: data, privateKey: privateKey)
    }
    
    /// 透過 privateKey + IV 將經過 AES256 加密的密文進行解密
    /// - Parameters:
    ///   - data: 密文 (經過 AES256 加密的原始資料)
    ///   - key: privateKey
    ///   - iv: 透過 func generateIV(preIV data: Data) -> Data 所產生的 IV
    /// - Returns: 產生經過 AES256 解密過後的明文
    func aes256Decrypted(cipherText data: Data, privateKey key: String, iv: String) -> Data? {
        return aes256Decrypt(cipherText: data, privateKey: key, iv: iv)
    }
    
    /// 將要上傳 Firebase Realtime Database 的資料透過 AES256 進行解密
    /// - Parameters:
    ///   - data: 密文 (要經過 AES256 加密的帳號密碼)
    ///   - key: BrowserUid 取第三及第五段組合作為 key
    /// - Returns: 產生經過 AES256 解密過後的明文
    func aes256DecryptedWithoutIV(cipherText data: Data, privateKey key: String) -> Data? {
        let privateKey = Array(key.utf8)
        return aes256DecryptWithoutIV(cipherText: data, privateKey: privateKey)
    }
    
    /// 將「`經過 AES256 加密過的密文` 與 `preIV`」轉成 hexString，並透過 `+` 串接起來
    /// - Parameters:
    ///   - data: 密文 (經過 AES256 加密的原始資料)
    ///   - preIV: 透過 func generatePreIV<T>(privateKey data: T) -> Data 所產生的 preIV
    /// - Returns: 產生 `密文.toHexString()+preIV.toHexString()` 格式的組合字串
    func combinedCipherTextAndPreIV(cipherText data: Data, preIV: Data) -> String {
        let cipherTextToHexString = data.toHexString()
        let preIVToHexString = preIV.toHexString()
        let combined = cipherTextToHexString + "+" + preIVToHexString
        return combined
    }
    
    /// 拆解出 `密文` 跟 `preIV`
    /// - Parameter data: 透過 func combinedCipherTextAndPreIV(cipherText data: Data, preIV: Data) -> String 所產生的組合字串
    /// - Returns: 拆解完的 `密文` 跟 `preIV`
    func splitCipherTextAndPreIV(combinedString data: String) -> (cipherText: String, preIV: String) {
        let splitArray = data.split(separator: "+")
        return (String(splitArray[0]), String(splitArray[1]))
    }
    
    /// 將 class 轉成 JSON Data
    /// - Parameter input: E，要轉成 JSON Data 的 class，class 需繼承 Encodable Protocol
    /// - Returns: 轉成 JSON Data 的 class
    func classToJsonData<E: Encodable>(input: E) -> Data? {
        let dic1 = try? input.asDictionary()
        let jsonData = try? JSONSerialization.data(withJSONObject: dic1 ?? [:], options: .prettyPrinted)
        return jsonData
    }
    
    /// 將 Json Data 轉回成 T
    /// - Parameter input: Json Data
    /// - Returns: T
    func jsonToModel<T: Codable>(input jsonData: Data) -> T? {
        do {
            let dic = try jsonData.asDictionary()
            #if DEBUG
            print("decryptedData to Json：", dic)
            #endif
            if T.self == PasswordModel.self {
                let pm = PasswordModel(id: dic["id"]!,
                                       title: dic["title"]!,
                                       account: dic["account"]!,
                                       password: dic["password"]!,
                                       url: dic["url"]!,
                                       note: dic["note"]!)
                return pm as? T
            } else if T.self == NotesModel.self {
                let nm = NotesModel(id: dic["id"]!,
                                    title: dic["title"]!,
                                    note: dic["note"]!)
                return nm as? T
            }
        } catch {
            print(error)
        }
        return nil
    }
}

// MARK: - 內部執行用 Function

private extension CryptoManager {
    
    /// 進行 SHA256 Hash (內部呼叫用)
    /// - Parameter data: privateKey
    /// - Returns: 經過 SHA256 Hash 過後的 privateKey
    func sha256HashEncrypt(privateKey data: Data) -> Data {
        let hash = data.sha256()
        return hash
    }
    
    /// 透過 privateKey + IV 將原始資料進行 AES256 加密 (內部呼叫用)
    /// - Parameters:
    ///   - data: 明文 (要經過 AES256 加密的原始資料)
    ///   - key: privateKey
    ///   - iv: 透過 func generateIV(preIV data: Data) -> Data 所產生的 IV
    /// - Returns: 產生經過 AES256 加密過後的密文
    func aes256Encrypt(clearText data: Data, privateKey key: String, iv: String) -> Data? {
        do {
            let aes = try AES(key: key, iv: iv, padding: .pkcs7) // 建立 AES Cryptor 實例
            let encryptedBytes = try aes.encrypt(data.bytes)
            let encryptedData = Data(encryptedBytes)
            return encryptedData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// 將要上傳 Firebase Realtime Database 的資料透過 AES256 進行加密 (內部呼叫用)
    /// - Parameters:
    ///   - data: 明文 (要經過 AES256 加密的帳號密碼)
    ///   - key: BrowserUid 取第三及第五段組合作為 key
    /// - Returns: 產生經過 AES256 加密過後的密文
    func aes256EncryptWithoutIV(clearText data: Data, privateKey key: Array<UInt8>) -> Data? {
        do {
            let aes = try AES(key: key, blockMode: ECB(), padding: .pkcs7) // 建立 AES Cryptor 實例
            let encryptedBytes = try aes.encrypt(data.bytes)
            let encryptedData = Data(encryptedBytes)
            return encryptedData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// 透過 privateKey + IV 將經過 AES256 加密的密文進行解密 (內部呼叫用)
    /// - Parameters:
    ///   - data: 密文 (經過 AES256 加密的原始資料)
    ///   - key: privateKey
    ///   - iv: 透過 func generateIV(preIV data: Data) -> Data 所產生的 IV
    /// - Returns: 產生經過 AES256 解密過後的明文
    func aes256Decrypt(cipherText data: Data, privateKey key: String, iv: String) -> Data? {
        do {
            let aes = try AES(key: key, iv: iv, padding: .pkcs7) // 建立 AES Cryptor 實例
            let decryptedBytes = try aes.decrypt(data.bytes)
            let decryptedData = Data(decryptedBytes)
            return decryptedData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// 將要上傳 Firebase Realtime Database 的資料透過 AES256 進行解密 (內部呼叫用)
    /// - Parameters:
    ///   - data: 密文 (要經過 AES256 加密的帳號密碼)
    ///   - key: BrowserUid 取第三及第五段組合作為 key
    /// - Returns: 產生經過 AES256 解密過後的明文
    func aes256DecryptWithoutIV(cipherText data: Data, privateKey key: Array<UInt8>) -> Data? {
        do {
            let aes = try AES(key: key, blockMode: ECB(), padding: .pkcs7) // 建立 AES Cryptor 實例
            let decryptedBytes = try aes.decrypt(data.bytes)
            let decryptedData = Data(decryptedBytes)
            return decryptedData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
