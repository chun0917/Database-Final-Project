//
//  Localizable.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/14.
//

import Foundation

enum LocalizableStrings: String {
    
    // MARK: - App 本體的

    // MARK: AppDelegate
    
    case Screenshot_detected = "Screenshot detected"
    case Screen_recording_detected = "Screen recording detected"
    
    // MARK: - General
    
    case Confirm = "Confirm"
    case Cancel = "Cancel"
    case Close = "Close"
    case Error = "Error"
    case Warnings = "Warnings"
    case Continue = "Continue"
    case Done = "Done"
    case Back = "Back"
    
    // MARK: - UITabBar Title
    
    case Password = "Password"
    case Notes = "Notes"
    case Settings = "Settings"
    case Register = "Register"
    
    // MARK: - UIMenu
    
    case Edit = "Edit"
    case Delete = "Delete"
    case Details = "Details"
    case The_selected_data_will_be_deleted_soon_and_cannot_be_recovered_after_deletion_Please_confirm_whether_to_continue = "The selected data will be deleted soon, and cannot be recovered after deletion. Please confirm whether to continue?"
    
    
    // MARK: - Initial Flow
    
    // MARK: LoginViewController
    
    case Login = "Login"
    case Forget_password = "Forget Password?"
    case Welcome = "Welcome to use the APP!"
    case Email_and_password_cannot_be_empty = "Email and Password cannot be empty!"
    case Please_input_valid_email = "Please input valid Email!"
    case Login_success = "Login Success"
    case Email_is_not_exist_or_incorrect_password = "Email isn't exist or incorrect password!"
    case Get_verify_code = "Get verify code"
    case Input_phone_number = "Input phone number"
    case Verify_code = "Verify code"
    case Input_verify_code = "Input verify code"
    case Reset_your_password_to_000000 = "Reset your password to 000000"
    case Phone_number_isnot_exist = "Phone number isn't exist"
    case Verify_code_is_incorrect_please_try_again = "Verify code is incorrect, please try again"
    
    // MARK: RegisterViewController
    case Email = "Email"
    case Phone = "Phone"
    case Confirm_password  = "Confirm Password"
    case Cancel_register = "Cancel Register"
    case Please_input_valid_email_or_phone = "Please input valid Email or Phone!"
    case Password_do_not_match = "Password don't match!"
    case Email_is_already_registered = "Email is already registered"
    case Phone_is_already_registered = "Phone is already registered"
    case Register_success = "Register success!"
    
    // MARK: - Password
    
    // MARK: PasswordMainViewController
    
    case The_QR_Code_format_is_wrong_it_can_only_be_used_to_scan_the_QR_Code_generated_by_the_Cmore_browser_extension = "The QR Code format is wrong, it can only be used to scan the QR Code generated by the Cmore browser extension."
    
    // MARK: AddPasswordViewController
    
    case Title = "Title"
    case Account = "Account"
    case URL = "URL"
    case Note = "Note"
    case Required = "Required"
    case Get_New_Password = "Get New Password"
    case Show_Advanced_Settings = "Show Advanced Settings"
    case Hide_Advanced_Settings = "Hide Advanced Settings"
    case Save_Password_Succeed = "Save Password Succeed!"
    case This_is_the_first_time_to_add_to_avoid_data_loss_please_remember_to_go_to_Settings_Backup_Restore_to_make_a_backup = "This is the first time to add, to avoid data loss, please remember to go to `Settings -> Backup/Restore` to make a backup!"
    
    // MARK: EditPasswordViewController
    
    case Edit_Password_Succeed = "Edit Password Succeed!"
    
    // MARK: GenerateRandomPasswordViewController
    
    case Security_Password_Generator = "Security Password Generator"
    case Re_Generate = "Re Generate"
    case Use_this_Password = "Use this Password"
    case Length = "Length"
    case Please_check_at_least_one_password_generation_rule = "Please check at least one password generation rule!"
    
    // MARK: - Notes
    
    // MARK: AddNotesViewController
   
    case Save_Notes_Succeed = "Save Notes Succeed!"
    
    // MARK: EditNotesViewController
    
    case Edit_Notes_Succeed = "Edit Notes Succeed!"
    
    // MARK: - Settings
    
    // MARK: SettingsViewController
    case Enable_AutoFill_Services = "Enable AutoFill Services"
    case Go_to_Settings = "Go to Settings"
    case Info = "Info"
    case Sign_Out = "Sign Out"
    case iCloud_Backup = "iCloud Backup"
    case Please_select_AutoFill_Service = "Please select AutoFill Service"
    case AutoFill_service_is_enabled = "AutoFill service is enabled"
    case Change_Password = "Change Password"
    case Sign_Out_Success = "Sign out success!"
    
    // MARK: - ChangePasswordViewController
    
    case Input_origin_password = "Input Origin Password"
    case Input_new_password = "Input New Password"
    case Confirm_new_password = "Confirm New Password"
    case Change_Password_Succeed = "Change Password Succeed!"
    case Origin_password_is_incorrect = "Origin Password is incorrect!"
    
    // MARK: CKBackupRestoreViewController
    
    case BackupRestore = "Backup／Restore"
    case Last_backup_time = "Last backup time"
    case Backup_to_iCloud = "Backup to iCloud"
    case Automatic_Backup = "Automatic Backup"
    case Delete_Backup_Data = "Delete Backup Data"
    case Restore_Backup_Data = "Restore Backup Data"
    case Backup_Data = "Backup Data"
    case Backup = "Backup"
    case Restore = "Restore"
    case Backing_up = "Backing up..."
    case Backup_Successful = "Backup Successful!"
    case Deleting_backup_data = "Deleting backup data..."
    case Restoring_backup_data = "Restoring backup data..."
    case Backup_data_restored_successfully = "Backup data restored successfully!"
    case iCloud_automatic_backup_in_background = "iCloud Automatic Backup in Background"
    case iCloud_automatic_backup_in_background_info_description1 = "If you want to perform iCloud background automatic backup smoothly"
    case iCloud_automatic_backup_in_background_info_description2 = "The system will run smoothly only if the following conditions are met"
    case iCloud_automatic_backup_in_background_info_part1 = "Turn on 'Background App Refresh' in Settings"
    case iCloud_automatic_backup_in_background_info_part2 = "The device needs to be connected to a power source"
    case iCloud_automatic_backup_in_background_info_part3 = "Need to be connected to a stable network"
    case iCloud_automatic_backup_in_background_info_part4 = "Keep the app inside the app switcher and lock the device"
    case Please_turn_on_the_Background_App_Refresh_function_of_App_to_perform_iCloud_background_automatic_backup_smoothly = "Please turn on the 'Background App Refresh' function of App to perform iCloud background automatic backup smoothly"
    case If_you_do_not_enable_the_Background_App_Refresh_function_you_will_not_be_able_to_perform_iCloud_background_automatic_backup_Do_you_want_to_enable_it = "If you do not enable the 'Background App Refresh' function, you will not be able to perform iCloud background automatic backup. Do you want to enable it?"
    case User_has_not_enabled_iCloud_access_for_iCloud_Drive_and_App_in_settings = "User has not enabled iCloud access for iCloud Drive and App in settings"
    case All_backup_data_stored_in_your_iCloud_will_be_deleted_Do_you_want_to_continue = "All backup data stored in your iCloud will be deleted. Do you want to continue?"
    case All_App_data_currently_stored_on_the_device_will_be_overwritten_Do_you_want_to_restore_the_data = "All App data currently stored on the device will be overwritten. Do you want to restore the data?"
    case If_there_is_a_previous_backup_this_operation_will_overwrite_all_App_data_currently_stored_in_iCloud_Do_you_want_to_backup = "If there is a previous backup, this operation will overwrite all App data currently stored in iCloud. Do you want to backup?"
    case Whether_to_go_to_the_settings_to_open = "Whether to go to the settings to open"
    case Backup_data_on_iCloud_has_been_deleted = "Backup data on iCloud has been deleted"
    case There_is_currently_no_backup_data_of_App_on_iCloud_Please_execute_Backup_to_iCloud_first_and_then_perform_this_operation = "There is currently no backup data of App on iCloud. Please execute「Backup to iCloud」first, and then perform this operation."
    case minutes15 = "15 Minutes"
    case minutes30 = "30 Minutes"
    case hour1 = "1 Hour"
    case hours2 = "2 Hours"
    case hours3 = "3 Hours"
    case never = "Never"
    case everyday = "Every Day"
    case every3days = "Every 3 Days"
    case everyweek = "Every Week"
    case every2weeks = "Every 2 Weeks"
    case everymonth = "Every Month"
    // MARK: - Add
    
    case Add = "Add"
    case Cancel_Add = "Cancel Add"
    case The_currently_entered_data_has_not_been_saved_Do_you_want_to_leave_this_screen = "The currently entered data has not been saved. Do you want to leave this screen?"
    case Please_make_sure_all_required_fields_are_entered = "Please make sure all required fields are entered"
    
    // MARK: - Edit
    
    case Cancel_Edit = "Cancel Edit"
    case Copy_Succeed = "Copy Succeed!"
    case Information_has_been_copied_to_the_scrapbook = "Information has been copied to the scrapbook"
    
    // MARK: - Search
    
    case Search = "Search"
    
    // MARK: - App Extension

    // MARK: AutoFillViewController
    case Extension_Save = "Extension_Save"
    case Please_login_first = "Please login first"
    case Extension_Add_Account = "Extension_Add Account"
}

/// 簡便翻譯
/// - Parameters:
///   - key: 在 enum LocalizableStrings 裡面定義的 Localizable.strings Key
/// - Returns: 在 Localizable.strings 裡面定義的 Value
func translate(_ key: LocalizableStrings) -> String {
    return NSLocalizedString(key.rawValue, comment: "")
}
