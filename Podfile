source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!

pod 'Alamofire'
pod 'AlamofireObjectMapper'
pod 'AlamofireNetworkActivityLogger'
pod 'AlamofireImage'
pod 'Fabric'
pod 'Crashlytics'
pod 'SwiftyUserDefaults'
pod 'KeychainSwift'
pod 'SwifterSwift'
pod 'DGCollectionViewPaginableBehavior', :git => 'https://github.com/hintoz/collection-view-paginable-behavior.git', :branch => 'develop'
pod 'Atributika'
pod 'CDMarkdownKit', :git => 'https://github.com/chrisdhaan/CDMarkdownKit'

pod 'Reveal-SDK', :configurations => ['Debug']
pod 'SwiftyBeaver'
pod 'R.swift'

target 'qinoa' do
    platform :ios, '9.0'
  
  pod 'LKAlertController'
  pod 'InteractiveSideMenu'
  
  pod 'EZPlayer', :git => 'https://github.com/hintoz/EZPlayer.git'
  pod 'SubtleVolume'
  
  pod 'Letters'
  pod 'RevealingSplashView'
  pod 'TMDBSwift', :path => '../TheMovieDatabaseSwiftWrapper/'
  pod 'CustomLoader'
  pod 'NotificationBannerSwift'
  pod 'Eureka'
  pod 'NTDownload', :git => 'https://github.com/hintoz/NTDownload.git'
  
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Performance'
  
  pod 'AZSearchView', :git => 'https://github.com/hintoz/AZSearchView.git'
  pod 'NDYoutubePlayer', :git => 'https://github.com/hintoz/NDYoutubePlayer.git'
  pod 'EasyAbout'
  pod 'CircleProgressView'
  pod 'GradientLoadingBar'
  pod 'UIEmptyState'
  
  pod 'Mixpanel'

end

target 'qinoaTV' do
    platform :tvos, '10.0'
end

post_install do |installer|
	myTargets = ['CustomLoader', 'DGCollectionViewPaginableBehavior']
	
	installer.pods_project.targets.each do |target|
		if myTargets.include? target.name
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_VERSION'] = '3.2'
			end
		end
	end
end
