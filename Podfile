# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PasswordAutoFill' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PasswordAutoFill
  pod 'FMDB/SQLCipher', '2.7.5'
  pod 'CryptoSwift', '1.5.1'
end

target 'Database Final Project' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for App
  pod 'IQKeyboardManagerSwift', '6.5.10'
  pod 'FMDB/SQLCipher', '2.7.5'
  pod 'CryptoSwift', '1.5.1'
  pod 'Firebase', '9.6.0'
  pod 'Firebase/Auth'
  pod 'FirebaseDatabase', '9.6.0'
  pod 'FirebaseMessaging', '9.6.0'
  pod 'FirebaseCrashlytics', '9.6.0'
  pod 'ReachabilitySwift', '5.0.0'
  pod 'ProgressHUD', '13.6.2'
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
