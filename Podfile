source 'https://github.com/cocoapods/specs.git'
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
pod 'DGCollectionViewPaginableBehavior', :path => '../collection-view-paginable-behavior/'
pod 'Atributika'
pod 'Kingfisher'
pod 'CDMarkdownKit', :git => 'https://github.com/chrisdhaan/CDMarkdownKit'
pod 'LKAlertController', :path => '../LKAlertController/'
pod 'Reveal-SDK', :configurations => ['Debug']
pod 'SwiftyBeaver'
pod 'Mixpanel'
pod 'R.swift'
pod 'PMKVObserver'
pod 'MarqueeLabel/Swift'
pod 'CryptoSwift'

target 'qinoa' do
    platform :ios, '9.0'
    
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
