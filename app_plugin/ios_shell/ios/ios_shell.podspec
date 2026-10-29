#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'ios_shell'
  s.version          = '1.0.0'
  s.summary          = 'iOS shell environment using ios_system framework'
  s.description      = <<-DESC
Self-contained shell environment for iOS using the ios_system framework
from the a-shell project. Provides Unix command execution capabilities.
                       DESC
  s.homepage         = 'https://github.com/gsmlg-app/web-terminal'
  s.license          = { :type => 'BSD-3-Clause', :file => '../LICENSE' }
  s.author           = { 'GSMLG' => 'me@gsmlg.org' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{c,h,m,swift}'
  s.preserve_paths   = 'Vendor/md5/*'
  # Keep plist in framework bundle for reference
  s.resources        = ['Classes/commandDictionary.plist', 'Resources/cacert.pem', 'Resources/Notices/*']

  s.dependency 'Flutter'

  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'

  # ios_system and related frameworks
  # These XCFrameworks should be downloaded and placed in the Frameworks directory
  s.vendored_frameworks = [
    'Frameworks/ios_system.xcframework',
    'Frameworks/shell.xcframework',
    'Frameworks/files.xcframework',
    'Frameworks/text.xcframework',
    'Frameworks/tar.xcframework',
    'Frameworks/awk.xcframework',
    'Frameworks/openssl.xcframework',
    'Frameworks/libssh2.xcframework',
    'Frameworks/curl_ios.xcframework',
    'Frameworks/network_ios.xcframework',
    'Frameworks/lua_ios.xcframework',
    'Frameworks/lg2.xcframework',
    'Frameworks/Python.xcframework'
  ]

  # Framework search paths
  s.xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/../.symlinks/plugins/ios_shell/ios/Frameworks"',
    'OTHER_LDFLAGS' => '$(inherited) -framework ios_system -framework shell -framework files -framework text -framework tar -framework awk -framework openssl -framework libssh2 -framework curl_ios -framework network_ios -framework lua_ios -framework lg2 -framework Python'
  }
end
