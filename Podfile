inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

link_with 'AppleWatchSBB', 'AppleWatchSBB WatchKit Extension'

target :'AppleWatchSBB' do
    pod 'SCLAlertView-Objective-C', '~> 0.7.0'
end

target :'AppleWatchSBB WatchKit Extension' do
    pod 'MediaRSSParser', '~> 1.0'
end

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        if target.name == "Pods-AppleWatchSBB WatchKit Extension-AFNetworking"
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'AF_APP_EXTENSIONS=1']
            end
        end
    end
end