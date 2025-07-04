Pod::Spec.new do |s|
  s.name = "DGCharts"
  s.version = "5.1.0"
  s.summary = "DGCharts is a powerful & easy to use chart library for iOS, tvOS and OSX (and Android)"
  s.homepage = "https://github.com/danielgindi/Charts"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = "Daniel Cohen Gindi", "Philipp Jahoda"
  s.ios.deployment_target = "12.0"
  s.tvos.deployment_target = "12.0"
  s.osx.deployment_target = "10.13"
  s.source = { :git => "https://github.com/danielgindi/Charts.git", :tag => "#{s.version}" }
  s.default_subspec = "Core"
  s.swift_version = '5.7'
  s.cocoapods_version = '>= 1.5.0'
  s.dependency 'Adjust', '~> 5.1.1'
  s.dependency 'AppsFlyerFramework', '~> 6.16.0'
  s.resource_bundles = {"DGCharts" => ["Source/Charts/PrivacyInfo.xcprivacy"]}
  
  s.subspec "Core" do |ss|
    ss.source_files  = "Source/Charts/**/*.swift"
  end
end
