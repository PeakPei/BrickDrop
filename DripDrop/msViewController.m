//
//  msViewController.m
//  Brick Drop
//
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//

#import "msViewController.h"
#import "msMyScene.h"

#import "GADBannerView.h"
#import "GADRequest.h"

@interface msViewController () {
    bool iadsBannerIsVisible;
}
@property(nonatomic, strong) GADBannerView *bannerView;

@end

@implementation msViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadAds];

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

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void) viewWillLayoutSubviews {
    // test to see if its okay to show iAds... if so, call...
}

-(void) loadAds {
    
    // Setup iAds
    _banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [_banner setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    _banner.delegate = self;
    iadsBannerIsVisible = YES;
    [self.view addSubview:_banner];
    NSLog(@"Showing iAd banner");

    // Setup AdMob
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    self.bannerView.hidden = YES;
    self.bannerView.adUnitID = @"ca-app-pub-8546202416581405/5925936775";
    self.bannerView.rootViewController = self;
    [self.view addSubview:self.bannerView];
    // Now Call with [self showBanner]
}

- (void)showBanner {
    self.bannerView.hidden = NO;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    [self.bannerView loadRequest:request];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    iadsBannerIsVisible = YES;
    [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
    [UIView commitAnimations];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    BOOL shouldExecuteAction = YES; // your app implements this method
    if (!willLeave && shouldExecuteAction){
        // insert code here to suspend any services that might conflict with the advertisement, for example, you might pause the game with an NSNotification like this...
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PauseScene" object:nil]; //optional
    }
    return shouldExecuteAction;
}

-(void) bannerViewActionDidFinish:(ADBannerView *)banner {
    //Unpause the game if you paused it previously.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UnPauseScene" object:nil]; //optional
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (iadsBannerIsVisible == YES) {
        
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        //iadsBannerIsVisible = NO;
    }
    NSLog(@"iAds failed");
    [self showBanner];
}

-(void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Ad Received");
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
    self.bannerView.hidden = YES;
}
@end
