//
//  msViewController.m
//  Brick Drop
//
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//

#import "msViewController.h"
#import "msMyScene.h"
#import "GADBannerView.h" // Google AdMob Banner

@interface msViewController () {
    bool iadsBannerIsVisible;
}
@property (nonatomic, strong) ADBannerView *iAdBannerView; // iAd
@property(nonatomic, strong) GADBannerView *adMobBannerView; // AdMob
@end

@implementation msViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAds]; // Setup Ad containers

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    SKScene * scene = [msMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void) viewWillLayoutSubviews {}

-(void) loadAds {
    // Setup iAds
    self.iAdBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [self.iAdBannerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    self.iAdBannerView.delegate = self;
    iadsBannerIsVisible = YES;
    [self.view addSubview:self.iAdBannerView];
    
    // Setup AdMob
    self.adMobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    self.adMobBannerView.hidden = YES;
    self.adMobBannerView.adUnitID = @"ca-app-pub-8546202416581405/5925936775";
    self.adMobBannerView.rootViewController = self;
    [self.view addSubview:self.adMobBannerView];
    // Now Call with [self showBanner]
}

- (void)showBanner {
    self.adMobBannerView.hidden = NO;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    [self.adMobBannerView loadRequest:request];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)iAdBannerView {
    iadsBannerIsVisible = YES;
    [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
    [UIView commitAnimations];
    NSLog(@"iAd loaded");
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)iAdBannerView willLeaveApplication:(BOOL)willLeave { // iAd banner touched
    BOOL shouldExecuteAction = YES; // your app implements this method
    if (!willLeave && shouldExecuteAction){
        // insert code here to suspend any services that might conflict with the advertisement, for example, you might pause the game with an NSNotification like this...
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"PauseScene" object:nil];
    }
    return shouldExecuteAction;
}

-(void) bannerViewActionDidFinish:(ADBannerView *)iAdBannerView { // iAd banner closed
    //Unpause the game if you paused it previously.
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"UnPauseScene" object:nil];
}

- (void)bannerView:(ADBannerView *)iAdBannerView didFailToReceiveAdWithError:(NSError *)error { // iAd failed to load
    if (iadsBannerIsVisible == YES) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        iAdBannerView.frame = CGRectOffset(iAdBannerView.frame, 0, -iAdBannerView.frame.size.height);
        [UIView commitAnimations];
        //iadsBannerIsVisible = NO;
    }
    NSLog(@"iAds failed");
    [self showBanner];
}

-(void)adViewDidReceiveAd:(GADBannerView *)adMobBannerView {
    NSLog(@"Ad Received");
}

-(void)adMobBannerView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
    self.adMobBannerView.hidden = YES;
}
@end
