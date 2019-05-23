Pod::Spec.new do |spec|

    spec.name               =   "CyberSwift"
    spec.platform           =   :ios, "11.0"
    spec.swift_version      =   "4.2"

    spec.summary            =   "Swift framework for Cyberway.golos.io"
    spec.homepage           =   "https://cyberway.golos.io/"
    spec.license            =   { :type => 'MIT', :file => 'LICENSE.md' }
    spec.author             =   "msm72"
    spec.source_files       =   "CyberSwift", "CyberSwift/**/*.{h,m,swift}"

    spec.version            =   "1.0.8"
    spec.source             =   { :git => "https://github.com/GolosChain/cyber-ios.git", :tag => "#{spec.version}" }

    # Cocoapods
    spec.dependency 'Checksum'
    spec.dependency 'Locksmith'
    spec.dependency 'RxSwift'
    spec.dependency 'RxCocoa'
    spec.dependency 'RxBlocking'
    spec.dependency 'GoloCrypto'
    spec.dependency 'SwiftTheme'
    spec.dependency 'CryptoSwift'
    spec.dependency 'RxStarscream'
    spec.dependency 'secp256k1.swift'
    spec.dependency 'eosswift', '~> 1.5'
    spec.dependency 'Starscream', '~> 3.0'
    spec.dependency 'Localize-Swift', '~> 2.0'

end