# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'

target 'CyberSwift' do
  # EOS framework
  pod 'eosswift', '~> 1.5'

  pod 'RxSwift'
  pod 'RxCocoa'

  pod 'Checksum'
  pod 'PDFReader'
  pod 'Locksmith'
  pod 'SwiftTheme'
  pod 'CryptoSwift'
  pod 'secp256k1.swift'
  pod 'Localize-Swift', '~> 2.0'
  
  # Websockets in swift for iOS and OSX
  #  pod 'Starscream', '~> 3.0'
  pod 'RxStarscream'
  pod 'SwiftyJSON', '~> 4.0'
  
  # GoloCrypto
  pod 'GoloCrypto', :git => "https://github.com/Monserg/GoloGrypto.git"
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['PDFReader'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4'
        end
      end
    end
  end

end
