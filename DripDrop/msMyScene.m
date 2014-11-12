//
//  msMyScene.m
//  Brick Drop
//
//  Created by Madison Spry on 07/08/2014.
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//
#import "msMyScene.h"
#import "msGameScene.h"
#import "msTimeAttackGameScene.h"

@interface msMyScene()
@property BOOL pressedPlayButton;
@property BOOL pressedBackButton;
@end

@implementation msMyScene
-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        //Add a background picture
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        background.zPosition = -21;
        [self addChild:background];
        //moving image
        SKTexture* cloudsTexture = [SKTexture textureWithImageNamed:@"background_clouds"];
        cloudsTexture.filteringMode = SKTextureFilteringNearest;
        SKAction* moveCloudsSprite = [SKAction moveByX:0 y:-cloudsTexture.size.height duration:0.1 * cloudsTexture.size.width*2];
        SKAction* resetCloudsSprite = [SKAction moveByX:0 y:cloudsTexture.size.height duration:0];
        SKAction* moveCloudsSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveCloudsSprite, resetCloudsSprite]]];
        for( int i = 0; i < 2 + self.frame.size.height / ( cloudsTexture.size.height *2); ++i ) {
            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:cloudsTexture];
            [sprite setScale:1.0];
            sprite.zPosition = -20;
            sprite.position = CGPointMake(sprite.size.width/2, i * sprite.size.height);
            [sprite runAction:moveCloudsSpritesForever];
            [self addChild:sprite];
        }
        //bottom image
        SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
        skylineTexture.filteringMode = SKTextureFilteringNearest;
        for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width * 2 ); ++i ) {
            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
            [sprite setScale:3.0];
            sprite.zPosition = -19;
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
            [self addChild:sprite];
        }
        //gameTitle logo
        SKSpriteNode *gameTitle = [SKSpriteNode spriteNodeWithImageNamed:@"gameTitle"];
        gameTitle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+95);
        [self addChild:gameTitle];
        
        [self setupMenu];
        
        //other labels
        SKLabelNode *copyrightLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        copyrightLabel.text = @"© MSPRY.NET 2014";
        copyrightLabel.fontColor = [UIColor blackColor];
        copyrightLabel.fontSize = 15;
        copyrightLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame)+90);
        copyrightLabel.name = @"copyrightLabel";
        [self addChild:copyrightLabel];
        
        SKLabelNode *versionLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        versionLabel.text = @"v1.1";
        versionLabel.fontColor = [UIColor blackColor];
        versionLabel.fontSize = 15;
        versionLabel.position = CGPointMake(CGRectGetMaxX(self.frame)-5-versionLabel.frame.size.width/2, CGRectGetMinY(self.frame)+5);
        versionLabel.name = @"versionLabel";
        [self addChild:versionLabel];
        
        //TEMP: Currency System beta for 1.1
        unsigned long currency = [[NSUserDefaults standardUserDefaults] integerForKey:@"gameCurrency"]; // Get Currency
        NSString *currencyString = [NSString stringWithFormat:@"Currency: %lu",currency];
        NSString *currencyLabelText = currencyString;
        SKLabelNode *currencyLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        currencyLabel.text = currencyLabelText;
        currencyLabel.fontColor = [UIColor blackColor];
        currencyLabel.fontSize = 15;
        currencyLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50);
        currencyLabel.name = @"currencyLabel";
        [self addChild:currencyLabel];
        
    }
    return self;
}
-(void) setupMenu {
    // Play Button
    SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"play_icon"];
    playButton.position = CGPointMake(CGRectGetMidX(self.frame)-50, CGRectGetMinY(self.frame)+150);
    playButton.name = @"SS_startGameButton";
    [self addChild:playButton];
    // Leaderboards Button
    SKSpriteNode *leaderboardsButton = [SKSpriteNode spriteNodeWithImageNamed:@"leaderboards_icon"];
    leaderboardsButton.position = CGPointMake(CGRectGetMidX(self.frame)+50, CGRectGetMinY(self.frame)+150);
    leaderboardsButton.name = @"SS_leaderboardsButton";
    [self addChild:leaderboardsButton];
    // Required to fix repetitive sound bug
    _pressedPlayButton = NO;
    _pressedBackButton = YES;
    //Version 1.1 Menu additions
    SKLabelNode *shopButton = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    shopButton.text = @"Shop";
    shopButton.fontColor = [UIColor blackColor];
    shopButton.fontSize = 15;
    shopButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame)+200);
    shopButton.name = @"shopButton";
    [self addChild:shopButton];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKAction *fadeOutMenu = [SKAction sequence:@[
                                                 [SKAction fadeOutWithDuration:0.2],
                                                 [SKAction waitForDuration:0.2],
                                                 [SKAction removeFromParent]
                                                 ]];
    SKNode *startGameButton = [self childNodeWithName:@"SS_startGameButton"];
    SKNode *startGameButton2 = [self childNodeWithName:@"SS_startGameButton2"];
    SKNode *playButtonText = [self childNodeWithName:@"playButtonText"];
    SKNode *timeAttackButton = [self childNodeWithName:@"SS_timeAttackButton"];
    SKNode *timeAttackButtonText = [self childNodeWithName:@"timeAttackButtonText"];
    SKNode *leaderboardsButton = [self childNodeWithName:@"SS_leaderboardsButton"];
    SKNode *GG_mainMenuButton = [self childNodeWithName:@"GG_mainMenuButton"];
    SKNode *GG_gameOverScreen = [self childNodeWithName:@"GG_gameOverScreen"];
    //Version 1.1 SKNode additions
    SKNode *shopButton = [self childNodeWithName:@"shopButton"];
    SKNode *buyYellowBall = [self childNodeWithName:@"buyYellowBall"];
    SKNode *useYellowBall = [self childNodeWithName:@"useYellowBall"];
    SKNode *useBlueBall = [self childNodeWithName:@"useBlueBall"];
    
    if ([startGameButton containsPoint:location]) { // Load menu with game mode selection
        if (_pressedPlayButton == NO) {
            _pressedPlayButton = YES;
            _pressedBackButton = NO;
            [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
            [startGameButton runAction:fadeOutMenu completion:^{
                [leaderboardsButton runAction:fadeOutMenu completion:^{
                    
                    SKSpriteNode *gameOverScreen = [SKSpriteNode spriteNodeWithImageNamed:@"gameOverScreen"];
                    gameOverScreen.name = @"GG_gameOverScreen";
                    gameOverScreen.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMinY(self.frame)+275));
                    gameOverScreen.alpha = 0;
                    [self addChild:gameOverScreen];
                    
                    SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"brickDropButtonIcon"];
                    playButton.position = CGPointMake(CGRectGetMidX(self.frame)-75, CGRectGetMinY(self.frame)+280);
                    playButton.name = @"SS_startGameButton2";
                    playButton.alpha = 0;
                    [self addChild:playButton];
                    
                    SKSpriteNode *playButtonText = [SKSpriteNode spriteNodeWithImageNamed:@"gameTitle"];
                    playButtonText.position = CGPointMake(playButton.position.x+80, playButton.position.y);
                    playButtonText.xScale = 0.5;
                    playButtonText.yScale = 0.5;
                    playButtonText.name = @"playButtonText";
                    playButtonText.alpha = 0;
                    [self addChild:playButtonText];
                    
                    SKSpriteNode *timeAttackButton = [SKSpriteNode spriteNodeWithImageNamed:@"timeAttack_icon"];
                    timeAttackButton.position = CGPointMake(CGRectGetMidX(self.frame)-75, CGRectGetMinY(self.frame)+220);
                    timeAttackButton.name = @"SS_timeAttackButton";
                    timeAttackButton.alpha = 0;
                    [self addChild:timeAttackButton];
                    
                    SKSpriteNode *timeAttackButtonText = [SKSpriteNode spriteNodeWithImageNamed:@"timeAttackLogo"];
                    timeAttackButtonText.position = CGPointMake(timeAttackButton.position.x+89, timeAttackButton.position.y);
                    timeAttackButtonText.xScale = 0.5;
                    timeAttackButtonText.yScale = 0.5;
                    timeAttackButtonText.name = @"timeAttackButtonText";
                    timeAttackButtonText.alpha = 0;
                    [self addChild:timeAttackButtonText];
                    
                    SKSpriteNode *backToMenu = [SKSpriteNode spriteNodeWithImageNamed:@"backToMenu_icon"];
                    backToMenu.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame)+150);
                    backToMenu.name = @"GG_mainMenuButton";
                    backToMenu.zPosition = 21;
                    backToMenu.alpha = 0;
                    [self addChild:backToMenu];
                    
                    [gameOverScreen runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    [playButton runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    [playButtonText runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    [timeAttackButton runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    [timeAttackButtonText runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    [backToMenu runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    
                }];
            }];

        }
    }
    if ([startGameButton2 containsPoint:location] || [playButtonText containsPoint:location]) { //BrickDrop Play button
        [playButtonText runAction:fadeOutMenu];
        [startGameButton2 runAction:fadeOutMenu completion:^{
            SKScene *msGameSceneLoad = [[msGameScene alloc] initWithSize:self.size];
            [self.view presentScene:msGameSceneLoad];
        }];
    }
    if ([timeAttackButton containsPoint:location] || [timeAttackButtonText containsPoint:location]) { //TimeAttack Play button
        [timeAttackButtonText runAction:fadeOutMenu];
        [timeAttackButton runAction:fadeOutMenu completion:^{
            SKScene *mstimeAttackGameSceneLoad = [[msTimeAttackGameScene alloc] initWithSize:self.size];
            [self.view presentScene:mstimeAttackGameSceneLoad];
        }];
    }
    if ([leaderboardsButton containsPoint:location]) { // Leaderboards Button
        [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
        [leaderboardsButton runAction:[SKAction fadeOutWithDuration:0.2]];
            GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
            if (gameCenterController != nil) {
                gameCenterController.gameCenterDelegate = self;
                gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
                UIViewController *vc = self.view.window.rootViewController;
                [vc presentViewController: gameCenterController animated: YES completion:^{
                    [leaderboardsButton runAction:[SKAction fadeAlphaTo:1 duration:0.2]];
                }];
            }
    }
    if ([GG_mainMenuButton containsPoint:location]) { // Back button
        if (_pressedBackButton == NO) {
            _pressedBackButton = YES;
            [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
            [GG_mainMenuButton runAction:fadeOutMenu completion:^{
                [startGameButton2 runAction:fadeOutMenu];
                [playButtonText runAction:fadeOutMenu];
                [timeAttackButton runAction:fadeOutMenu];
                [timeAttackButtonText runAction:fadeOutMenu];
                [useBlueBall runAction:fadeOutMenu];
                [useYellowBall runAction:fadeOutMenu];
                [buyYellowBall runAction:fadeOutMenu];
                [GG_gameOverScreen runAction:fadeOutMenu completion:^{
                    [self setupMenu];
                }];
            }];
        }
    }
    if ([shopButton containsPoint:location]) { // Shop button
        if (_pressedPlayButton == NO) {
            _pressedPlayButton = YES;
            _pressedBackButton = NO;
            [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
            [shopButton runAction:fadeOutMenu completion:^{
                [startGameButton runAction:fadeOutMenu];
                [leaderboardsButton runAction:fadeOutMenu completion:^{
                    
                    SKSpriteNode *gameOverScreen = [SKSpriteNode spriteNodeWithImageNamed:@"gameOverScreen"];
                    gameOverScreen.name = @"GG_gameOverScreen";
                    gameOverScreen.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMinY(self.frame)+275));
                    gameOverScreen.alpha = 0;
                    [self addChild:gameOverScreen];
                    
                    SKSpriteNode *backToMenu = [SKSpriteNode spriteNodeWithImageNamed:@"backToMenu_icon"];
                    backToMenu.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame)+150);
                    backToMenu.name = @"GG_mainMenuButton";
                    backToMenu.zPosition = 21;
                    backToMenu.alpha = 0;
                    [self addChild:backToMenu];
                    
                    unsigned long boughtYellowBall = [[NSUserDefaults standardUserDefaults] integerForKey:@"boughtYellowBall"];
                    if (boughtYellowBall != 1) {
                        SKLabelNode *yellowBall = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                        yellowBall.text = @"Buy Yellow Ball: 5 Currency";
                        yellowBall.fontColor = [UIColor blackColor];
                        yellowBall.fontSize = 15;
                        yellowBall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-20);
                        yellowBall.name = @"buyYellowBall";
                        yellowBall.alpha = 0;
                        yellowBall.zPosition = 22;
                        [self addChild:yellowBall];
                        [yellowBall runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    } else if (boughtYellowBall == 1) {
                        SKLabelNode *yellowBall = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                        yellowBall.text = @"Use Yellow Ball";
                        yellowBall.fontColor = [UIColor blackColor];
                        yellowBall.fontSize = 15;
                        yellowBall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-20);
                        yellowBall.name = @"useYellowBall";
                        yellowBall.alpha = 0;
                        yellowBall.zPosition = 22;
                        [self addChild:yellowBall];
                        [yellowBall runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    }
                    SKLabelNode *blueBall = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                    blueBall.text = @"Use Blue Ball";
                    blueBall.fontColor = [UIColor blackColor];
                    blueBall.fontSize = 15;
                    blueBall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-60);
                    blueBall.name = @"useBlueBall";
                    blueBall.alpha = 0;
                    blueBall.zPosition = 22;
                    [self addChild:blueBall];
                    
                    [gameOverScreen runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    [backToMenu runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                    [blueBall runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
                }];
            }];
        }
    }
    
    if ([buyYellowBall containsPoint:location]) { // Buy Yellow Ball button
        unsigned long currency = [[NSUserDefaults standardUserDefaults] integerForKey:@"gameCurrency"]; // Get Currency
        if (currency >= 5) {
            //Price
            currency -= 5;
            
            //Update Currency Label, maybe put this in a function?
            //remove old label
            SKNode *oldCurrencyLabel = [self childNodeWithName:@"currencyLabel"];
            [oldCurrencyLabel removeFromParent];
            //add updated label with new currency level
            NSString *currencyString = [NSString stringWithFormat:@"Currency: %lu",currency];
            NSString *currencyLabelText = currencyString;
            SKLabelNode *currencyLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            currencyLabel.text = currencyLabelText;
            currencyLabel.fontColor = [UIColor blackColor];
            currencyLabel.fontSize = 15;
            currencyLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50);
            currencyLabel.name = @"currencyLabel";
            [self addChild:currencyLabel];
            
            
            [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
            //write to user defaults that Yellow has been bought, remove the paid currency, then switch to yellow ball
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"ballColour"];//Tell the game to use yellow ball
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"boughtYellowBall"];//Yellow ball bought, save this
            [[NSUserDefaults standardUserDefaults] setInteger:currency forKey:@"gameCurrency"]; // Set gameCurrency
            [[NSUserDefaults standardUserDefaults] synchronize]; // Save defaults
            
            [buyYellowBall removeFromParent];
            SKLabelNode *yellowBall = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            yellowBall.text = @"Use Yellow Ball";
            yellowBall.fontColor = [UIColor blackColor];
            yellowBall.fontSize = 15;
            yellowBall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-20);
            yellowBall.name = @"useYellowBall";
            yellowBall.alpha = 0;
            yellowBall.zPosition = 22;
            [self addChild:yellowBall];
            [yellowBall runAction:[SKAction fadeAlphaTo:1 duration:0.25]];
            
        } else { // Player doesnt have enough currency to buy the item
            [self runAction:[SKAction playSoundFileNamed:@"thud.m4a" waitForCompletion:NO]];
            NSLog(@"not enough currency");
        }
        
    }
    if ([useBlueBall containsPoint:location]) {
        [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ballColour"];//Tell the game to use blue ball
    }
    if ([useYellowBall containsPoint:location]) {
        [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"ballColour"];//Tell the game to use yellow ball
    }

}
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}
@end