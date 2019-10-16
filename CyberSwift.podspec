Pod::Spec.new do |spec|

    spec.name               =   "CyberSwift"
    spec.platform           =   :ios, "11.0"
    spec.swift_version      =   "4.2"

    spec.summary            =   "Swift framework for Cyberway.golos.io"
    spec.homepage           =   "https://cyberway.golos.io/"
    spec.license            =   { :type => 'MIT', :file => 'LICENSE.md' }
    spec.author             =   "msm72"
    spec.source_files       =   "CyberSwift", "CyberSwift/**/*.{h,m,swift}"

    spec.version            =   "1.0.9"
    spec.source             =   { :git => "https://github.com/GolosChain/cyber-ios.git", :tag => "#{spec.version}" }

    # Cocoapods
    spec.dependency 'Checksum'
    spec.dependency 'Locksmith'
    spec.dependency 'RxSwift'
    spec.dependency 'RxCocoa'
    spec.dependency 'GoloCrypto'
    spec.dependency 'SwiftTheme'
    spec.dependency 'CryptoSwift'
    spec.dependency 'Starscream'
    spec.dependency 'secp256k1.swift'
    spec.dependency 'eosswift', '~> 1.5'
    spec.dependency 'Localize-Swift', '~> 2.0'
    spec.dependency 'ReachabilitySwift', '~> 4.3.1'
    spec.dependency 'SwiftyJSON', '~> 4.0'
end
