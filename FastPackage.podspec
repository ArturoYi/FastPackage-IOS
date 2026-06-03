Pod::Spec.new do |s|
  s.name             = 'FastPackage'
  s.version          = '0.0.1'
  s.summary          = 'FastPackage iOS 开源组件库'
  s.description      = <<-DESC
    FastPackage 提供可复用的 iOS 能力封装，支持 Swift Package Manager 与 CocoaPods 集成。
    最低系统要求 iOS 14+。
  DESC
  s.homepage         = 'https://github.com/ArturoYi/FastPackage-IOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ArturoYi' => 'lzm.cyr@gmail.com' }
  s.source           = { :git => 'https://github.com/ArturoYi/FastPackage-IOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.9'

  s.source_files = 'Sources/FastPackage/**/*.swift'
  s.module_name = 'FastPackage'
  s.frameworks = 'UIKit'
end
