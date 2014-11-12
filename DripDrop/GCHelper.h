//
//  GCHelper.h
//  Brick Drop
//
//  Created by Madison Spry on 02/09/2014.
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject {
    
    BOOL gameCentreAvailable;
    BOOL userAuthenticated;
    
}

@property (assign, readonly) BOOL gameCentreAvailable;

+ (GCHelper *)sharedInstance;

-(void)authenticateLocalUser;


@end