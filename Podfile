# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

inhibit_all_warnings!

target 'FileTransfer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  

  pod 'YYKit'
  pod 'Masonry'
  pod 'ReactiveObjC'
  pod 'PromisesObjC'
  
  pod 'SGQRCode', '~> 4.1.0'
  
#  target 'example-OCTests' do
#    inherit! :search_paths
#    # Pods for testing
#  end
#
#  target 'example-OCUITests' do
#    # Pods for testing
#  end

end

post_install do |installer|
  puts 'Determining pod project minimal deployment target'
  
#  pods_project = installer.pods_project
  deployment_target_key = 'IPHONEOS_DEPLOYMENT_TARGET'
#  deployment_targets = pods_project.build_configurations.map{ |config| config.build_settings[deployment_target_key] }
#  minimal_deployment_target = deployment_targets.min_by{ |version| Gem::Version.new(version) }
#
#  puts 'Minimal deployment target is ' + minimal_deployment_target
#  puts 'Setting each pod deployment target to ' + minimal_deployment_target
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings[deployment_target_key] = '12.0'
    end
  end

end
