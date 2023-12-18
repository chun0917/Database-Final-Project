//
//  LocalDatabase.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/23.
//

import Foundation
import FMDB

protocol LocalDatabaseDelegate: NSObjectProtocol {
    /// 註冊
    /// - Parameters:
    ///    - id: 該筆資料的 UUID().uuidString
    ///    - email: 該筆資料的email
    ///    - phone: 該筆資料的phone
    ///    - password: 該筆資料的password
    ///    - table: 要新增資料到哪張 SQL Table
    func register(id: String, email: String, phone: String, password: String, table: LocalDatabase.SQLCommands)
    
    /// 新增資料
    ///  - Parameters:
    ///    - id: 該筆資料的 UUID().uuidString
    ///    - cipherText: 該筆資料經過加密過後的 CipherText (HexString)
    ///    - table: 要新增資料到哪張 SQL Table
    func insert(id: String,userID: String, cipherText: String, table: LocalDatabase.SQLCommands)
    
    /// 撈取資料
    /// - Parameters:
    ///   - table: 要撈取哪張 SQL Table 內的資料
    /// - Returns: [T]
    func fetch<T: Codable>(table: LocalDatabase.SQLCommands) -> [T]
    
    /// 撈取要備份到 iCloud 的資料
    /// - Parameters:
    ///   - table: 要撈取哪張 SQL Table 內的資料
    /// - Returns: [T]
    func fetchToCloud<T>(table: LocalDatabase.SQLCommands) -> [T]
    
    /// 更新資料
    ///  - Parameters:
    ///    - id: 該筆資料的 UUID().uuidString
    ///    - cipherText: 該筆資料經過加密過後的 CipherText (HexString)
    ///    - table: 要更新哪張 SQL Table 的資料
    func update(id: String, userID: String, cipherText: String, table: LocalDatabase.SQLCommands)
    
    /// 刪除資料
    ///  - Parameters:
    ///    - id: 該筆資料的 UUID().uuidString
    ///    - table: 要刪除哪張 SQL Table 的資料
    func delete(id: String, table: LocalDatabase.SQLCommands)
    
    /// 刪除全部資料
    ///  - Parameters:
    ///    - table: 要刪除哪張 SQL Table 內的全部資料
    func deleteAll(table: LocalDatabase.SQLCommands)
}

class LocalDatabase: NSObject {
    
    static let shared = LocalDatabase()
    
    var fileName: String = "Database.db"
    var filePath: String = ""
    var database: FMDatabase!
    
    private let cryptoManager = CryptoManager()
    
    private override init() {
        super.init()
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - enum SQL 指令
    
    /// enum SQL 指令
    enum SQLCommands {
        case user
        
        case password
        
        case note
        
        var create: String {
            switch self {
            case .user:
                return "CREATE TABLE USER(userID VARCHAR(50), email VARCHAR(50), phone VARCHAR(10), password VARCHAR(50), PRIMARY KEY(userID, email, phone))"
            case .password:
                return "CREATE TABLE PASSWORD(id VARCHAR(50) PRIMARY KEY,userID VARCHAR(50), cipherText VARCHAR(1000))"
            case .note:
                return "CREATE TABLE NOTE(id VARCHAR(50) PRIMARY KEY,userID VARCHAR(50), cipherText VARCHAR(1000))"
            }
        }
        
        var insert: String {
            switch self {
            case .user:
                return "INSERT INTO USER(userID,email,phone,password) VALUES (?,?,?,?)"
            case .password:
                return "INSERT INTO PASSWORD(id, userID, cipherText) VALUES (?,?,?)"
            case .note:
                return "INSERT INTO NOTE(id, userID, cipherText) VALUES (?,?,?)"
            }
        }
        
        var update: String {
            switch self {
            case .user:
                return "UPDATE USER SET password = ? WHERE userID = ?"
            case .password:
                return "UPDATE PASSWORD SET cipherText = ? WHERE id = ? AND userID = ?"
            case .note:
                return "UPDATE NOTE SET cipherText = ? WHERE id = ? AND userID = ?"
            }
        }
        
        var fetch: String {
            switch self {
            case .user:
                return "SELECT * FROM USER WHERE email = ? AND password = ?"
            case .password:
                return "SELECT * FROM PASSWORD WHERE userID = ?"
            case .note:
                return "SELECT * FROM NOTE WHERE userID = ?"
            }
        }
        
        var delete: String {
            switch self {
            case .user:
                return "DELETE FROM USER WHERE userID = ?"
            case .password:
                return "DELETE FROM PASSWORD WHERE id = ? AND userID = ?"
            case .note:
                return "DELETE FROM NOTE WHERE id = ? AND userID = ?"
            }
        }
        
        var deleteAll: String {
            switch self {
            case .user:
                return "DELETE FROM USER"
            case .password:
                return "DELETE FROM PASSWORD"
            case .note:
                return "DELETE FROM NOTE"
            }
        }
    }
    
    // MARK: - 連線到 SQL DB
    
    /// 判斷是否成功連線至資料庫
    func connectDB() -> Bool {
        var isOpen: Bool = false
        self.database = FMDatabase(path: self.filePath)
        if self.database != nil {
            if self.database.open() {
                isOpen = true
            } else {
                print("未連線至資料庫")
            }
        }
        return isOpen
    }
    
    // MARK: - 建立 SQL Table
    
    /// 建立資料表
    func createTable() {
        let fileManager: FileManager = FileManager.default
        let fileURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppDefine.appGroupsIdentifier)
        print("fileURL: \(fileURL!.path)")
        let fileURLPath = fileURL!.path + "/" + self.fileName
        self.filePath = fileURLPath
        if !fileManager.fileExists(atPath: fileURLPath) {
            if self.connectDB() {
                let createUserTable = SQLCommands.user.create
                let createPasswordCipherTable = SQLCommands.password.create
                let createNotesCipherTable = SQLCommands.note.create

                self.database.executeStatements(createUserTable)
                self.database.executeStatements(createPasswordCipherTable)
                self.database.executeStatements(createNotesCipherTable)
                // 將 SQL 路徑儲存到 UserDefaults
                UserPreferences.shared.databasePath = self.filePath
                print("成功建立資料表於\(self.filePath)")
            }
        } else {
            print("檔案已存在於 \(self.filePath)")
        }
    }
}

// MARK: - LocalDatabaseDelegate

extension LocalDatabase: LocalDatabaseDelegate {
    func register(id: String, email: String, phone: String, password: String, table: SQLCommands) {
        if connectDB() {
            let sqlCommand = table.insert
            if !database.executeUpdate(sqlCommand, withArgumentsIn: [id, email, phone, password]) {
                print("註冊失敗！")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func insert(id: String,userID: String, cipherText: String, table: SQLCommands) {
        if connectDB() {
            let sqlCommand = table.insert
            if !database.executeUpdate(sqlCommand, withArgumentsIn: [id, userID, cipherText]) {
                print("新增 cipherText 失敗！")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func fetch<T>(table: SQLCommands) -> [T] where T : Decodable, T : Encodable {
        var model: [T] = []
        if connectDB() {
            let sqlCommand = table.fetch
            do {
                let dataLists: FMResultSet = try database.executeQuery(sqlCommand, values: [UserPreferences.shared.userID])
                while dataLists.next() {
                    if let cipherText_id = dataLists.string(forColumn: "id"),
                       let cipherText = dataLists.string(forColumn: "cipherText") {

                        let spiltStr = cryptoManager.splitCipherTextAndPreIV(combinedString: cipherText)
                        
                        let privateKey = UserPreferences.shared.privateKeyForDatabase
                        let iv = cryptoManager.generateIV(preIV: spiltStr.preIV.hexadecimal!)
                        let ivToString = iv.toHexString()
                        
                        let decrypted_cipherText = cryptoManager.aes256Decrypted(cipherText: spiltStr.cipherText.hexadecimal!,
                                                                                 privateKey: privateKey,
                                                                                 iv: ivToString)

                        guard let decrypted_cipherText_toJsonString = String(data: decrypted_cipherText!, encoding: .utf8) else {
                            print("decrypted_cipherText_toJsonData Failed！")
                            return model // 回傳空陣列
                        }
                        
                        switch table {
                        case .user:
                            break
                        case .password:
                            guard let decrypted_cipherText_toJsonData: PasswordModel = cryptoManager.jsonToModel(input: decrypted_cipherText!) else {
                                print("decrypted_cipherText_cipherText_toJsonString Failed！")
                                return model // 回傳空陣列
                            }
                            
                            #if DEBUG
                            print("===============PASSWORD CIPHER START==============")
                            print("id: ", cipherText_id)
                            print("cipherText: ", decrypted_cipherText_toJsonString)
                            print("title: ", decrypted_cipherText_toJsonData.title)
                            print("account: ", decrypted_cipherText_toJsonData.account)
                            print("password: ", decrypted_cipherText_toJsonData.password)
                            print("url: ", decrypted_cipherText_toJsonData.url)
                            print("note: ", decrypted_cipherText_toJsonData.note)
                            print("===============PASSWORD CIPHER END==============")
                            #endif

                            model.append(decrypted_cipherText_toJsonData as! T)
                        case .note:
                            guard let decrypted_cipherText_toJsonData: NotesModel = cryptoManager.jsonToModel(input: decrypted_cipherText!) else {
                                print("decrypted_cipherText_cipherText_toJsonString Failed！")
                                return model // 回傳空陣列
                            }
                            
                            #if DEBUG
                            print("===============NOTES CIPHER START==============")
                            print("id: ", cipherText_id)
                            print("cipherText: ", decrypted_cipherText_toJsonString)
                            print("title: ", decrypted_cipherText_toJsonData.title)
                            print("note: ", decrypted_cipherText_toJsonData.note)
                            print("===============NOTES CIPHER END==============")
                            #endif
                            
                            model.append(decrypted_cipherText_toJsonData as! T)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return model
    }
    
    func fetchToCloud<T>(table: SQLCommands) -> [T] {
        var model: [T] = []
        if connectDB() {
            let sqlCommand = table.fetch
            do {
                let dataLists: FMResultSet = try database.executeQuery(sqlCommand, values: [UserPreferences.shared.userID])
                while dataLists.next() {
                    if let cipherText_id = dataLists.string(forColumn: "id"),
                       let cipherText = dataLists.string(forColumn: "cipherText") {

                        let spiltStr = cryptoManager.splitCipherTextAndPreIV(combinedString: cipherText)
                        
                        #if DEBUG
                        print("===============TO CLOUD START==============")
                        print("id: ", cipherText_id)
                        print("cipherText: ", spiltStr.cipherText)
                        print("preIV: ", spiltStr.preIV)
                        print("===============TO CLOUD END==============")
                        #endif
                        
                        switch table {
                        case .user:
                            break
                        case .password:
                            model.append(PasswordTable(id: cipherText_id, cipherText: cipherText) as! T)
                        case .note:
                            model.append(NotesTable(id: cipherText_id, cipherText: cipherText) as! T)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return model
    }
    
    func update(id: String, userID: String, cipherText: String, table: SQLCommands) {
        if connectDB() {
            let sqlCommand = table.update
            do {
                try database.executeUpdate(sqlCommand, values: [cipherText, id, UserPreferences.shared.userID])
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
    }
    
    func delete(id: String, table: SQLCommands) {
        if connectDB() {
            let sqlCommand = table.delete
            
            if !database.executeUpdate(sqlCommand, withArgumentsIn: [id,UserPreferences.shared.userID]) {
                print("刪除失敗！")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func deleteAll(table: SQLCommands) {
        if connectDB() {
            let sqlCommand = table.deleteAll
            
            if !database.executeUpdate(sqlCommand, withArgumentsIn: []) {
                print("刪除全部資料失敗！")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
}
