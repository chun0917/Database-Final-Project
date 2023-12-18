//
//  CloudKitDatabase.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/13.
//

import Foundation
import CloudKit

protocol CloudKitDatabaseDelegate: NSObjectProtocol {
    
    /// 檢查使用者是否開啟 App 的 iCloud 存取權限
    /// - Returns: CKAccountStatus
    func checkCKAccountStatus() async throws -> CKAccountStatus
    
    /// 檢查使用者的 iCloud Database 內是否存在資料
    /// - Throws: CKDatabaseError
    /// - Returns: true = 有資料；false = 沒資料
    func checkCKDatabaseDataIsExist() async throws -> Bool
    
    /// 備份資料到 iCloud
    /// - Parameters:
    ///   - password: 要備份的密碼資料
    ///   - notes: 要備份的記事資料
    /// - Throws: CKDatabaseError
    func backup(password: [PasswordTable], notes: [NotesTable]) async throws
    
    /// 備份密碼資料到 iCloud
    /// - Parameters:
    ///   - passwords: 要備份的密碼資料
    /// - Throws: CKDatabaseError
    func backupPassword(passwords: [PasswordTable]) async throws
    
    /// 備份記事資料到 iCloud
    /// - Parameters:
    ///   - notes: 要備份的記事資料
    /// - Throws: CKDatabaseError
    func backupNotes(notes: [NotesTable]) async throws
    
    /// 背景處理任務，自動備份至 iCloud
    /// - Throws: CKDatabaseError
    func backgroundProcessingTaskBackup() async throws
    
    /// 從 CloudKit Database 上抓取密碼與記事備份資料
    /// - Throws: CKDatabaseError
    /// - Returns: 撈取到的密碼備份資料、記事備份資料
    func fetch() async throws -> (password: [PasswordTable], notes: [NotesTable])
    
    /// 刪除 CloudKit Database 上所有的備份資料
    ///  - Throws: CKDatabaseError
    func delete() async throws
}

class CloudKitDatabase: NSObject {
    
    static let shared = CloudKitDatabase()
    
    // MARK: - Variables
    
    private let database = CKContainer.default().publicCloudDatabase
    
    private let cryptoManager = CryptoManager()
    
    // MARK: - enum
    
    /// CloudKit Database Record Type enum
    enum CKRecordType: String {
        
        /// CloudKit Database 的 Password Record Type
        case password = "Password"
        
        /// CloudKit Database 的 Notes Record Type
        case note = "Note"
    }
    
    /// CloudKit Database Error enum
    enum CKDatabaseError: Error {
        // MARK: General
        
        /// 密碼備份資料儲存完為空
        case passwordRecordNil
        
        /// 記事備份資料儲存完為空
        case notesRecordNil
        
        // MARK: Backup
        
        /// 備份前資料刪除失敗
        case deleteFailedBeforeBackup(Error)
        
        /// 密碼資料備份失敗
        case passwordBackupFailed(Error)
        
        /// 記事資料備份失敗
        case notesBackupFailed(Error)
        
        // MARK: Fetch
        
        /// 密碼備份資料抓取失敗
        case passwordFetchFailed(Error)
        
        /// 記事備份資料抓取失敗
        case notesFetchFailed(Error)
        
        // MARK: Delete
        
        /// 密碼備份資料刪除失敗
        case passwordDeleteFailed(Error)
        
        /// 記事備份資料刪除失敗
        case notesDeleteFailed(Error)
    }
    
    // MARK: - 檢查使用者的 iCloud 存取權限
    
    /// 檢查使用者是否開啟 App 的 iCloud 存取權限
    /// - Returns: CKAccountStatus
    func checkCKAccountStatus() async throws -> CKAccountStatus {
        return try await CKContainer.default().accountStatus()
    }
    
    // MARK: - 檢查 iCloud Database 內是否存在資料
    
    /// 檢查使用者的 iCloud Database 內是否存在資料
    /// - Throws: CKDatabaseError
    /// - Returns: true = 有資料；false = 沒資料
    func checkCKDatabaseDataIsExist() async throws -> Bool {
        let result = try await fetch()
        return result.password.count > 0 || result.notes.count > 0
    }
    
    // MARK: - Backup to iCloud Database
    
    /// 備份資料到 iCloud
    /// - Parameters:
    ///   - password: 要備份的密碼資料
    ///   - notes: 要備份的記事資料
    /// - Throws: CKDatabaseError
    func backup(password: [PasswordTable], notes: [NotesTable]) async throws {
        do {
            try await delete()
            do {
                try await backupPassword(passwords: password)
                print("密碼資料備份完成！")
                do {
                    try await backupNotes(notes: notes)
                    print("記事資料備份完成！")
                } catch {
                    throw CKDatabaseError.notesBackupFailed(error)
                }
            } catch {
                throw CKDatabaseError.passwordBackupFailed(error)
            }
        } catch {
            throw CKDatabaseError.deleteFailedBeforeBackup(error)
        }
    }
    
    /// 備份密碼資料到 iCloud
    /// - Parameters:
    ///   - passwords: 要備份的密碼資料
    /// - Throws: CKDatabaseError
    func backupPassword(passwords: [PasswordTable]) async throws {
        let recordType = CKRecordType.password.rawValue
        
        for password in passwords {
            let record = CKRecord(recordType: recordType)
            record.setValue(password.id, forKey: "dataID")
            record.setValue(password.cipherText, forKey: "cipherText")
            
            do {
                try await database.save(record)
            } catch {
                throw CKDatabaseError.passwordBackupFailed(error)
            }
        }
    }
    
    /// 備份記事資料到 iCloud
    /// - Parameters:
    ///   - notes: 要備份的記事資料
    /// - Throws: CKDatabaseError
    func backupNotes(notes: [NotesTable]) async throws {
        let recordType = CKRecordType.note.rawValue
        
        for note in notes  {
            let record = CKRecord(recordType: recordType)
            record.setValue(note.id, forKey: "dataID")
            record.setValue(note.cipherText, forKey: "cipherText")
            
            do {
                try await database.save(record)
            } catch {
                throw CKDatabaseError.notesBackupFailed(error)
            }
        }
    }
    
    /// 背景處理任務，自動備份至 iCloud
    /// - Throws: CKDatabaseError
    func backgroundProcessingTaskBackup() async throws {
        let passwordTable: [PasswordTable] = LocalDatabase.shared.fetchToCloud(table: .password)
        let notesTable: [NotesTable] = LocalDatabase.shared.fetchToCloud(table: .note)
        try await backup(password: passwordTable, notes: notesTable)
    }
    
    // MARK: - Fetch From iCloud Database
    
    /// 從 CloudKit Database 上抓取密碼與記事備份資料 (await/async)
    /// - Throws: CKDatabaseError
    /// - Returns: 撈取到的密碼備份資料、記事備份資料
    func fetch() async throws -> (password: [PasswordTable], notes: [NotesTable]) {
        let password = try await fetchPasswordFromCloud()
        let notes = try await fetchNotesFromCloud()
        return (password, notes)
    }
    
    // MARK: - Delete Backup Data From iCloud Database
    
    /// 刪除 CloudKit Database 上所有的備份資料 (await/async)
    ///  - Throws: CKDatabaseError
    func delete() async throws {
        try await deleteAll(table: .password)
        try await deleteAll(table: .note)
    }
}

// MARK: - CloudKitDatabase 內部呼叫 Function

private extension CloudKitDatabase {
    
    // MARK: Fetch
    
    /// 從 CloudKit Database 上抓取密碼備份資料 (await/async)
    ///  - Throws: CKDatabaseError
    ///  - Returns: 撈取到的密碼備份資料
    func fetchPasswordFromCloud() async throws -> [PasswordTable] {
        var passwordArray: [PasswordTable] = []
        
        let recordType = CKRecordType.password.rawValue
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "dataID", ascending: true)]
        do {
            let result = try await database.records(matching: query)
            switch result {
            case (let matchResults, _):
                try matchResults.compactMap { $0.1 }.forEach { record in
                    switch record {
                    case .success(let ckRecord):
                        guard let password: PasswordTable = ckRecordToTable(record: ckRecord, table: .password) else {
                            return
                        }
                        passwordArray.append(password)
                    case .failure(let error):
                        print("CKRecord Add to Password Error：", error.localizedDescription)
                        throw CKDatabaseError.passwordRecordNil
                    }
                }
                return passwordArray
            }
        } catch {
            throw CKDatabaseError.passwordFetchFailed(error)
        }
    }
    
    /// 從 CloudKit Database 上抓取記事備份資料 (await/async)
    ///  - Throws: CKDatabaseError
    ///  - Returns: 撈取到的記事備份資料
    func fetchNotesFromCloud() async throws -> [NotesTable] {
        var notesArray: [NotesTable] = []
        
        let recordType = CKRecordType.note.rawValue
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "dataID", ascending: true)]
        do {
            let result = try await database.records(matching: query)
            switch result {
            case (let matchResults, _):
                try matchResults.compactMap { $0.1 }.forEach { record in
                    switch record {
                    case .success(let ckRecord):
                        guard let notes: NotesTable = ckRecordToTable(record: ckRecord, table: .note) else {
                            return
                        }
                        notesArray.append(notes)
                    case .failure(let error):
                        print("CKRecord Add to Notes Error：", error.localizedDescription)
                        throw CKDatabaseError.notesRecordNil
                    }
                }
                return notesArray
            }
        } catch {
            throw CKDatabaseError.notesFetchFailed(error)
        }
    }
    
    // MARK: Delete
    
    /// 刪除 CloudKit Database 上所有的備份資料
    /// - Parameters:
    ///   - table: 要刪除哪張 CKRecord Table 的備份資料
    /// - Throws: CKDatabaseError
    func deleteAll(table: CKRecordType) async throws {
        var recordArray: [CKRecord] = []
        let query = CKQuery(recordType: table.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "dataID", ascending: true)]
        do {
            let result = try await database.records(matching: query)
            switch result {
            case (let matchResults, _):
                try matchResults.compactMap { $0.1 }.forEach { record in
                    switch record {
                    case .success(let ckRecord):
                        recordArray.append(ckRecord)
                    case .failure(let error):
                        print(error.localizedDescription)
                        switch table {
                        case .password:
                            throw CKDatabaseError.passwordRecordNil
                        case .note:
                            throw CKDatabaseError.notesRecordNil
                        }
                    }
                }
                for record in recordArray {
                    do {
                        let _ = try await database.deleteRecord(withID: record.recordID)
                    } catch {
                        switch table {
                        case .password:
                            throw CKDatabaseError.passwordDeleteFailed(error)
                        case .note:
                            throw CKDatabaseError.notesDeleteFailed(error)
                        }
                    }
                }
            }
        } catch {
            switch table {
            case .password:
                throw CKDatabaseError.passwordFetchFailed(error)
            case .note:
                throw CKDatabaseError.notesFetchFailed(error)
            }
        }
    }
    
    // MARK: CKRecord convert to Struct
    
    /// 將 CKRecord 轉換成 CloudKit Table Entity
    /// - Parameters:
    ///   - record: CKRecord
    ///   - table: 要轉換的 CloudKit Table Entity
    /// - Returns: T
    func ckRecordToTable<T>(record: CKRecord, table: CKRecordType) -> T? {
        guard let dataID = record.value(forKey: "dataID") as? String else {
            return nil
        }
        guard let cipherText = record.value(forKey: "cipherText") as? String else {
            return nil
        }
        
        let spiltStr = cryptoManager.splitCipherTextAndPreIV(combinedString: cipherText)
                
        let privateKey = UserPreferences.shared.privateKeyForDatabase
        let iv = cryptoManager.generateIV(preIV: spiltStr.preIV.hexadecimal!)
        let ivToString = iv.toHexString()
        
        let decrypted = cryptoManager.aes256Decrypted(cipherText: spiltStr.cipherText.hexadecimal!,
                                                      privateKey: privateKey,
                                                      iv: ivToString)
        
        guard let decrypted_cipherText_toJsonString = String(data: decrypted!, encoding: .utf8) else {
            print("decrypted_cipherText_toJsonData Failed！")
            return nil
        }
        
        switch table {
        case .password:
            guard let password: PasswordModel = cryptoManager.jsonToModel(input: decrypted!) else {
                print("CKRecord to PasswordModel Failed！")
                return nil
            }
            
            #if DEBUG
            print("===============ICLOUD PASSWORD CIPHER START==============")
            print("cipherText: ", decrypted_cipherText_toJsonString)
            print("id: ", password.id)
            print("title: ", password.title)
            print("account: ", password.account)
            print("password: ", password.password)
            print("url: ", password.url)
            print("note: ", password.note)
            print("===============ICLOUD PASSWORD CIPHER END==============")
            #endif
            
            let passwordCipher = PasswordTable(recordID: record.recordID, id: dataID, cipherText: cipherText)
            return passwordCipher as? T
        case .note:
            guard let note: NotesModel = cryptoManager.jsonToModel(input: decrypted!) else {
                print("CKRecord to NotesModel Failed！")
                return nil
            }
            
            #if DEBUG
            print("===============ICLOUD NOTES CIPHER START==============")
            print("cipherText: ", decrypted_cipherText_toJsonString)
            print("id: ", note.id)
            print("title: ", note.title)
            print("note: ", note.note)
            print("===============ICLOUD NOTES CIPHER END==============")
            #endif
            
            let notesCipher = NotesTable(recordID: record.recordID, id: dataID, cipherText: cipherText)
            return notesCipher as? T
        }
    }
}

// MARK: - CloudKitDatabaseDelegate

extension CloudKitDatabase: CloudKitDatabaseDelegate {}
