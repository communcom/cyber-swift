# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'

def common_pods
  # EOS framework
  pod 'eosswift', :git => "https://github.com/communcom/eos-swift.git"
  
  pod 'RxSwift'
  pod 'RxCocoa'
  
  pod 'Checksum'
  pod 'Locksmith'
  pod 'SwiftTheme'
  pod 'CryptoSwift'
  pod 'secp256k1.swift'
  pod 'Localize-Swift', '~> 2.0'
  
  # Websockets in swift for iOS and OSX
  #  pod 'Starscream', '~> 3.0'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'Starscream'
  pod 'ReachabilitySwift', '~> 4.3.1'
  
  # GoloCrypto
  pod 'GoloCrypto', :git => "https://github.com/Monserg/GoloGrypto.git"
end

target 'CyberSwift' do
  common_pods
end

target 'CyberSwiftTests' do
  common_pods
end
