#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mbautomation.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mbautomation'
  s.version          = '0.0.1'
  s.summary          = 'MBAutomation plugin for MBurger.'
  s.description      = <<-DESC
MBAutomation plugin for MBurger.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.framework    = 'UserNotifications'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
