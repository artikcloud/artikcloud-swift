Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "ArtikCloudSwift"
  s.version      = "4.2.0"
  s.summary      = "ARTIK Cloud SDK for iOS, tvOS, watchOS & macOS, fully written in Swift."
  s.homepage     = "https://github.com/artikcloud/artikcloud-swift"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = { :type => 'Apache License, Version 2.0' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author       = { "ARTIK Cloud" => "support@artik.cloud" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source        = { :git => "https://github.com/artikcloud/artikcloud-swift.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "Source/*.swift"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

  s.dependency 'Alamofire', '~> 4.7.1'
  s.dependency 'PromiseKit', '6.2.3'
  s.dependency 'ObjectMapper', '~> 3.1.0'
  s.dependency 'CryptoSwift', '~> 0.9.0'
  s.dependency 'Starscream', '~> 3.0.5'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }

  s.cocoapods_version  = '>= 1.1'

end
