//
//  msAppDelegate.h
//  Brick Drop
//
//  Created by Madison Spry on 07/08/2014.
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface msAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSSet *inAppProductIdentifiers;
-(NSString *)removeAdsProductIdentifier;

@end
