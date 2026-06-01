Pod::Spec.new do |s|
  s.name         = 'TopOnVungleAdapter'
  s.version      = '1.0.3'
  s.summary      = 'Custom TopOn Vungle adapter for iOS.'
  s.description  = <<-DESC
  Custom TopOn Vungle adapter packaged as a CocoaPods binary dependency.
  DESC

  s.homepage     = 'https://github.com/WindsSunShine/TopOnVungleAdapter'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'WindsSunShine' => 'zhangjianjunapple@gmail.com' }

  s.platform     = :ios, '12.0'
  s.source       = {
    :git => 'https://github.com/WindsSunShine/TopOnVungleAdapter.git',
    :tag => s.version.to_s
  }

  s.static_framework = true

  # TopOn 下载出来的 Vungle Adapter
  s.vendored_frameworks = 'Frameworks/AnyThinkVungleAdapter.xcframework'

  # TopOn 主 SDK，版本要和下载这个 Adapter 时选择的 TopOn SDK 版本一致
  # 项目使用 TPNiOS 体系时不能再依赖 AnyThinkiOS，否则会重复引入 AnyThinkSDK.xcframework
  s.dependency 'TPNiOS'

  # Vungle 官方 SDK，不要把 VungleAdsSDK.xcframework 重复打包进来
  # 版本号需要和 TopOn 下载包内置的 VungleAdsSDK.xcframework 保持一致
  s.dependency 'VungleAds', '= 7.7.3'

  s.frameworks = [
    'UIKit',
    'Foundation',
    'StoreKit',
    'AdSupport',
    'AppTrackingTransparency',
    'AVFoundation',
    'WebKit',
    'SystemConfiguration'
  ]

  s.libraries = ['z', 'sqlite3', 'c++']
end
