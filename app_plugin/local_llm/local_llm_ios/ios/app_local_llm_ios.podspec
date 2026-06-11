Pod::Spec.new do |s|
  s.name             = 'app_local_llm_ios'
  s.version          = '0.1.0'
  s.summary          = 'iOS implementation of app_local_llm'
  s.description      = <<-DESC
iOS implementation of app_local_llm plugin.
                       DESC
  s.homepage         = 'https://github.com/app'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'GSMLG Team' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '17.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
