#
# Be sure to run `pod lib lint XZRefreshing.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZRefreshing'
  s.version          = '1.0.0'
  s.summary          = '一款 iOS 下拉刷新组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       组件 XZRefreshing 支持高度自定义，适合需要自定义下拉刷新功能业务
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZRefreshing'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'developer@xezun.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZRefreshing.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZRefreshing/Code/**/*.{h,m}'
    ss.project_header_files = 'XZRefreshing/Code/**/Private/*.h'
  end
  
  s.subspec 'Debug' do |ss|
    ss.dependency 'XZRefreshing/Code'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_DEBUG=1' }
  end
  
  # s.resource_bundles = {
  #   'XZRefreshing' => ['XZRefreshing/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

