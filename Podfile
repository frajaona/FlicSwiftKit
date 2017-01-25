source 'https://git.groriri.me/frajaona/privatepods.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

def cas_pods()
	pod 'CocoaAsyncSocket', '~> 7.5.0'
end

def socks_pods()
  pod 'socks', '~> 1.0.3'
end

target 'FlicSwiftKitiOS' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FlicSwiftKitiOS
  cas_pods()

  target 'FlicSwiftKitiOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'FlicSwiftKitMacOS' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FlicSwiftKitMacOS
  socks_pods()

  target 'FlicSwiftKitMacOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'FlicSwiftKitTvOS' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FlicSwiftKitTvOS
  cas_pods()

  target 'FlicSwiftKitTvOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
