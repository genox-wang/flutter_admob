#import "FlutterAdmobPlugin.h"
@import GoogleMobileAds;

@interface InterstitialAdWrapper : NSObject <GADInterstitialDelegate>
  @property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation InterstitialAdWrapper

+ (UIViewController *)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)show : (NSString *)adUnitId {
  self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitId];
  self.interstitial.delegate = self;
  [self.interstitial loadRequest:[GADRequest request]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  NSLog(@"interstitialDidReceiveAd");
  if (self.interstitial.isReady) {
    [self.interstitial presentFromRootViewController:[InterstitialAdWrapper rootViewController]];
  }
}

@end

@interface RewardedVideoAdWrapper : NSObject <GADRewardBasedVideoAdDelegate>
@end
// @interface RewardedVideoAdWrapper () <GADRewardBasedVideoAdDelegate>
// @end
@implementation RewardedVideoAdWrapper

- (void)show : (NSString *)adUnitId  {
   [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request]
      withAdUnitID:adUnitId];
   [GADRewardBasedVideoAd sharedInstance].delegate = self;
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward *)reward {
  // NSString *rewardMessage =
  // [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
  //     reward.type,
  //     [reward.amount doubleValue]];
  // NSLog(rewardMessage);
}

+ (UIViewController *)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad is received.");
  if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:[RewardedVideoAdWrapper rootViewController]];
  }
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad has completed.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad is closed.");
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
  NSLog(@"Reward based video ad failed to load.");
}
@end

@interface FlutterAdmobPlugin ()
@property(nonatomic, strong) RewardedVideoAdWrapper *rewardedWrapper;
@property(nonatomic, strong) InterstitialAdWrapper *interstitialWrapper;
@property(nonatomic, strong) GADBannerView *bannerView;
@end

@implementation FlutterAdmobPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_admob"
            binaryMessenger:[registrar messenger]];
  FlutterAdmobPlugin* instance = [[FlutterAdmobPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  instance.rewardedWrapper = [RewardedVideoAdWrapper alloc];
  instance.interstitialWrapper = [InterstitialAdWrapper alloc];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    NSString *appId = (NSString *)call.arguments[@"app_id"];
    [GADMobileAds configureWithApplicationID: appId];
    result(@"1");
  } else if ([@"show_rewardvideo" isEqualToString:call.method]) {
    NSString *adUnitId = (NSString *)call.arguments[@"unit_id"];
    [self.rewardedWrapper show:adUnitId ];
  } else if ([@"show_interstitial" isEqualToString:call.method]) {
    NSString *adUnitId = (NSString *)call.arguments[@"unit_id"];
    [self.interstitialWrapper show: adUnitId];
  } else if([@"show_banner" isEqualToString: call.method]) {
    NSString *adUnitId = (NSString *)call.arguments[@"unit_id"];
    int size = [(NSNumber *)call.arguments[@"size"] intValue];
    int gravity = [(NSNumber *)call.arguments[@"gravity"] intValue];
    double offset = [(NSString *)call.arguments[@"anchor_offset"] doubleValue]; 
    NSLog(@"%@ %d %d %f", adUnitId, size, gravity, offset);
    [self showBanner : adUnitId size: size gravity: gravity offset: offset];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void) showBanner : (NSString *)adUnitId  size: (int)size  gravity:(int)gravity offset:(double)offset {
    self.bannerView = [[GADBannerView alloc]
      initWithAdSize:[self getADSize: size]];
    [self addBannerViewToView:self.bannerView  gravity: gravity offset: offset];
    self.bannerView.adUnitID = adUnitId;
    self.bannerView.rootViewController = [FlutterAdmobPlugin rootViewController];
    [self.bannerView loadRequest:[GADRequest request]];
}

+ (UIViewController *)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)addBannerViewToView:(UIView *)bannerView  gravity: (int)gravity  offset: (double)offset{
  UIView *screen = [FlutterAdmobPlugin rootViewController].view;
  bannerView.translatesAutoresizingMaskIntoConstraints = NO;
  [screen addSubview:bannerView];

#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
  if (@available(ios 11.0, *)) {
    NSLog(@"ios 11.0");
    UILayoutGuide *guide = screen.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
      [bannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
      [bannerView.bottomAnchor
        constraintEqualToAnchor: gravity == 0 ? guide.topAnchor : guide.bottomAnchor
          constant:gravity == 0 ? offset : -offset]
    ]];
  } else {
    [self placeBannerPreIos11 : bannerView gravity: gravity offset: offset];
  }
#else
  [self placeBannerPreIos11 : bannerView gravity: gravity offset: offset];
#endif
}

- (void)placeBannerPreIos11:(UIView *)bannerView  gravity: (int)gravity offset: (double)offset {
  NSLog(@"placeBannerPreIos11");
  UIView *screen = [FlutterAdmobPlugin rootViewController].view;
  CGFloat x = screen.frame.size.width / 2 - bannerView.frame.size.width / 2;
  CGFloat y;
  if (gravity == 1) {
    y = screen.frame.size.height - bannerView.frame.size.height + offset;
  } else {
    y = offset;
  }
  bannerView.frame = (CGRect){{x, y}, bannerView.frame.size};
  [screen addSubview:bannerView];
}

- (GADAdSize) getADSize: (int) size {
  GADAdSize adSize = kGADAdSizeBanner;
  NSLog(@"size: %d", size);
  if (size == 0) {
    NSLog(@"1000");
    adSize = kGADAdSizeBanner;
  } else if (size == 1) {
    NSLog(@"1000");
    adSize = kGADAdSizeLargeBanner;
  } else if (size == 2) {
    NSLog(@"1000");
    adSize = kGADAdSizeMediumRectangle;
  } else if (size == 3) {
    NSLog(@"1000");
    adSize = kGADAdSizeFullBanner;
  } else if (size == 4) {
    NSLog(@"1000");
    adSize = kGADAdSizeLeaderboard;
  } else if (size == 5) {
    NSLog(@"1000");
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
      adSize = kGADAdSizeSmartBannerPortrait;
    } else {
      adSize = kGADAdSizeSmartBannerLandscape;
    }
  }
  return adSize;
}

@end
