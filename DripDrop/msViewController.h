//
//  msViewController.h
//  Brick Drop
//
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"

@class GADBannerView, GADRequest;

@interface msViewController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *banner;

@end