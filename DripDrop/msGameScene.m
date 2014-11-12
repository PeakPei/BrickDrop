//
//  msGameScene.m
//  Brick Drop
//
//  Created by Madison Spry on 07/08/2014.
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//

#import "msGameScene.h"
#import "msMyScene.h"

static const uint32_t ballCategory = 0x1 << 0;
static const uint32_t bricksCategory = 0x1 << 1;
static const uint32_t powersCategory = 0x1 << 2;

@interface msGameScene()
@property BOOL contentCreated;
@property SKTexture* platformTexture1;
@property SKTexture* platformTexture2;
@property SKAction* movePipesAndRemove;
@property SKNode* platforms;
@property SKSpriteNode* ball;
@property BOOL gameOver;
@property BOOL gameStarted;
@property BOOL shouldIChangeColour;
@property BOOL lastWasPlatform;
@property BOOL spawnedFirstPlatform;
@property int scoreNumber;
@property unsigned long currency;
@property double blendFactor;
@property float platformMovementDuration;
@end

@implementation msGameScene
-(void)didMoveToView:(SKView *)view { //Checks if the view has loaded
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}
-(void)createSceneContents { //Create Scene Contents
    _currency = [[NSUserDefaults standardUserDefaults] integerForKey:@"gameCurrency"]; // Get Currency
    NSLog(@"Currency: %lu",_currency);
    
    self.physicsWorld.contactDelegate = self;
    [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
    // Background
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.name = @"background";
    background.zPosition = -21;
    [self addChild:background];
    self.scaleMode = SKSceneScaleModeAspectFit;
    _blendFactor = 0.1;
    //bottom image
    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        [sprite setScale:3.0];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
        [self addChild:sprite];
    }
    //parent that contains platforms
    _platforms = [SKNode node];
    [self addChild:_platforms];
    //starts game
    _gameStarted = NO;
    [self startGame];
}
-(void)startGame {
    // Essential Sprites
    [self addSafeGuards];
    [self addControls];
    [self addBall];
    _gameStarted = YES;
    // Show game instructions
    SKSpriteNode *instructions = [SKSpriteNode spriteNodeWithImageNamed:@"instructions"];
    instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    instructions.zPosition = 5;
    instructions.name = @"instructions";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"showInstructions"] == nil) {
        [userDefaults setInteger:3 forKey:@"showInstructions"];
        [userDefaults synchronize];
    }
    unsigned long showInstructions = [userDefaults integerForKey:@"showInstructions"];
    if (showInstructions > 0) {
        [self addChild:instructions];
        showInstructions--;
        [userDefaults setInteger:showInstructions forKey:@"showInstructions"];
        [userDefaults synchronize];
    }
    //gameTitle logo
    SKSpriteNode *gameTitle = [SKSpriteNode spriteNodeWithImageNamed:@"gameTitle"];
    gameTitle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+95);
    gameTitle.name = @"gameTitle";
    [self addChild:gameTitle];
    NSString *gameSubTitleText;
    SKLabelNode *gameSubTitle = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    switch (arc4random_uniform(7)+1) {
        case 1:
            gameSubTitleText = @"Fall Down to get points!";
            break;
        case 2:
            gameSubTitleText = @"How far can you make it?";
            break;
        case 3:
            gameSubTitleText = @"Do these things ever end?";
            break;
        case 4:
            gameSubTitleText = @"Go fast, but not too fast!";
            break;
        case 5:
            gameSubTitleText = @"Jump from wall to wall!";
            break;
        case 6:
            gameSubTitleText = @"Does it ever end!?";
            break;
        case 7:
            gameSubTitleText = @"Try to get a Platinum Medal!";
            break;
        default:
            break;
    }
    gameSubTitle.text = gameSubTitleText;
    gameSubTitle.fontColor = [UIColor blackColor];
    gameSubTitle.fontSize = 15;
    gameSubTitle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+60);
    gameSubTitle.name = @"gt_gameSubTitle";
    [self addChild:gameSubTitle];
    SKAction* removeInstructions = [SKAction sequence:@[
                                                 [SKAction waitForDuration:1.5],
                                                 [SKAction fadeOutWithDuration:1],
                                                 [SKAction removeFromParent]
                                                 ]];
    [instructions runAction: removeInstructions];
    [gameTitle runAction:removeInstructions];
    [gameSubTitle runAction:removeInstructions];
    // Platforms
    _platformMovementDuration = 4;
    [self runAction:[SKAction repeatAction:[SKAction sequence:@[
                                                                [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                                                [SKAction waitForDuration:1.0]
                                                                ]] count:10] completion:^{
        [self runAction:[SKAction repeatAction:[SKAction sequence:@[
                                                                    [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                                                    [SKAction waitForDuration:0.9]
                                                                    ]] count:10] completion:^{
            [self runAction:[SKAction repeatAction:[SKAction sequence:@[
                                                                        [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                                                        [SKAction waitForDuration:0.85]
                                                                        ]] count:15] completion:^{
                [self runAction:[SKAction repeatAction:[SKAction sequence:@[
                                                                            [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                                                            [SKAction waitForDuration:0.8]
                                                                            ]] count:15] completion:^{
                    [self runAction:[SKAction repeatAction:[SKAction sequence:@[
                                                                                [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                                                                [SKAction waitForDuration:0.75]
                                                                                ]] count:15] completion:^{
                        [self runAction:[SKAction repeatAction:[SKAction sequence:@[
                                                                                    [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                                                                    [SKAction waitForDuration:0.7]
                                                                                    ]] count:10] completion:^{
                            [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                                        [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                                                                        [SKAction waitForDuration:0.6]
                                                                                        ]]]];
                        }];
                    }];
                }];
            }];
        }];
    }];
    // Score
    NSString* scoreString = @"0"; // Sets starting score to 0
    [self score:scoreString]; // Adds Score Counter
}
-(void)addPlatform {
    _platformTexture1 = [SKTexture textureWithImageNamed:@"platform1"];
    _platformTexture1.filteringMode = SKTextureFilteringNearest;
    _platformTexture2 = [SKTexture textureWithImageNamed:@"platform2"];
    _platformTexture2.filteringMode = SKTextureFilteringNearest;
    CGFloat distanceToMove = self.frame.size.height + 2 * _platformTexture1.size.height;
    SKAction* movePipes = [SKAction moveByX:0 y:distanceToMove duration:_platformMovementDuration];
    SKAction* removePipes = [SKAction removeFromParent];
    _movePipesAndRemove = [SKAction sequence:@[movePipes, removePipes]];
    SKAction* spawn;
    if (_lastWasPlatform == YES && _spawnedFirstPlatform == YES) {
        spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
        _lastWasPlatform = NO;
    } else if (_spawnedFirstPlatform == YES) {
        spawn = [SKAction performSelector:@selector(spawnPlatforms) onTarget:self];
        _lastWasPlatform = YES;
    } else if (_spawnedFirstPlatform == NO) {
        spawn = [SKAction performSelector:@selector(spawnFirstPlatform) onTarget:self];
    }
    SKAction* delay = [SKAction waitForDuration:10];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    [self runAction:spawnThenDelay];
}
-(void)spawnFirstPlatform { // Always starts game with platform in the middle
    SKSpriteNode *firstPlatform = [SKSpriteNode spriteNodeWithTexture:_platformTexture1];
    firstPlatform.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMinY(self.frame));
    firstPlatform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:firstPlatform.size];
    firstPlatform.physicsBody.dynamic = NO;
    firstPlatform.physicsBody.categoryBitMask = bricksCategory;
    firstPlatform.physicsBody.contactTestBitMask = ballCategory;
    firstPlatform.name = @"platform";
    [firstPlatform setScale:2.25];
    [_platforms addChild:firstPlatform];
    [firstPlatform runAction: _movePipesAndRemove];
    _spawnedFirstPlatform = YES;
    _lastWasPlatform = YES;
}
-(void)spawnPipes {
    SKNode* pipePair = [SKNode node];
    pipePair.position = CGPointMake( 0, CGRectGetMinY(self.frame) - _platformTexture1.size.height );
    pipePair.zPosition = 50;
    pipePair.name = @"platform";
    
    CGFloat horizontalDoubleGap = arc4random_uniform(150) +50;
    CGFloat x = arc4random_uniform(100) +1 ;
    
    SKSpriteNode* platform1 = [SKSpriteNode spriteNodeWithTexture:_platformTexture1];
    [platform1 setScale:2.25];
    platform1.position = CGPointMake(x, CGRectGetMinY(self.frame));
    platform1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform1.size];
    platform1.physicsBody.dynamic = NO;
    platform1.physicsBody.categoryBitMask = bricksCategory;
    platform1.physicsBody.contactTestBitMask = ballCategory;
    platform1.name = @"platform1";
    [pipePair addChild:platform1];
    
    SKSpriteNode* platform2 = [SKSpriteNode spriteNodeWithTexture:_platformTexture2];
    [platform2 setScale:2.25];
    platform2.position = CGPointMake(x + platform1.size.width + horizontalDoubleGap, CGRectGetMinY(self.frame));
    platform2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform2.size];
    platform2.physicsBody.dynamic = NO;
    platform2.physicsBody.categoryBitMask = bricksCategory;
    platform2.physicsBody.contactTestBitMask = ballCategory;
    platform2.name = @"platform2";
    [pipePair addChild:platform2];
    
    /* DISABLED FOR 1.0.2
    if (arc4random_uniform(100)+1 == 1) {
        SKSpriteNode *powerUp = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(10,10)];
        powerUp.position = CGPointMake(platform1.position.x,CGRectGetMinY(self.frame)+10);
        powerUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerUp.size];
        powerUp.physicsBody.dynamic = NO;
        powerUp.physicsBody.categoryBitMask = powersCategory;
        powerUp.physicsBody.contactTestBitMask = ballCategory;
        powerUp.name = @"powerUp";
        [_platforms addChild:powerUp];
        [powerUp runAction: _movePipesAndRemove];
    } else if (arc4random_uniform(100)+1 == 2) {
        SKSpriteNode *powerUp = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(10,10)];
        powerUp.position = CGPointMake(platform2.position.x,CGRectGetMinY(self.frame)+10);
        powerUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerUp.size];
        powerUp.physicsBody.dynamic = NO;
        powerUp.physicsBody.categoryBitMask = powersCategory;
        powerUp.physicsBody.contactTestBitMask = ballCategory;
        powerUp.name = @"powerUp";
        [_platforms addChild:powerUp];
        [powerUp runAction: _movePipesAndRemove];
    }
    */
    
    [pipePair runAction:_movePipesAndRemove];
    [_platforms addChild:pipePair];
}
-(void)spawnPlatforms {
    CGFloat widthGap = arc4random_uniform(CGRectGetMaxX(self.frame))+1;
    SKSpriteNode *platform = [SKSpriteNode spriteNodeWithTexture:_platformTexture1];
    platform.position = CGPointMake(widthGap,CGRectGetMinY(self.frame));
    platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform.size];
    platform.physicsBody.dynamic = NO;
    platform.physicsBody.categoryBitMask = bricksCategory;
    platform.physicsBody.contactTestBitMask = ballCategory;
    platform.name = @"platform";
    [platform setScale:2.25];
    [_platforms addChild:platform];
    [platform runAction: _movePipesAndRemove];
    
    /* DISABLED FOR 1.0.2
    if (arc4random_uniform(100)+1 == 1) {
        SKSpriteNode *powerUp = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(10,10)];
        powerUp.position = CGPointMake(platform.position.x,CGRectGetMinY(self.frame)+20);
        powerUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerUp.size];
        powerUp.physicsBody.dynamic = NO;
        powerUp.physicsBody.categoryBitMask = powersCategory;
        powerUp.physicsBody.contactTestBitMask = ballCategory;
        powerUp.name = @"powerUp";
        [_platforms addChild:powerUp];
        [powerUp runAction: _movePipesAndRemove];
    }
    */
    
}
-(SKLabelNode *) score:(NSString*)scoreString {
    SKLabelNode *scoreTitle = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    scoreTitle.text = scoreString;
    scoreTitle.fontSize = 30;
    scoreTitle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-105);
    scoreTitle.name = @"scoreTitle";
    scoreTitle.zPosition = 100;
    [self addChild:scoreTitle];
    return scoreTitle;
}
-(void)scoreCounter {
    SKNode *platform = [_platforms childNodeWithName:@"platform"];
    SKNode *scoreTitle = [self childNodeWithName:@"scoreTitle"];
    if ([platform.name isEqualToString:@"platform"] && _ball.position.y < platform.position.y && _gameOver == NO) {
        platform.name = nil;
        _scoreNumber++; //Increases Score
        if (_platformMovementDuration > 2.5 && _scoreNumber > 10) {
            _platformMovementDuration -= 0.05;
        }
        [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
        // Change background colour
        if (_scoreNumber % 20 == 0) {
            _shouldIChangeColour = YES;
        }
        NSString *scoreString = [@(_scoreNumber) stringValue];
        if (scoreTitle.name != nil) {
            SKAction *removeScoreLabel = [SKAction sequence:@[ // Moves up then removes platforms from scene
                                                              [SKAction removeFromParent],
                                                              [SKAction waitForDuration:0.1]
                                                              ]];
            [scoreTitle runAction:removeScoreLabel];
        }
        [self score:scoreString];
    }
}
-(SKSpriteNode *)addBall {
    
    //Get NSDefaults info on ball colour and use that colour
    unsigned long ballColour = [[NSUserDefaults standardUserDefaults] integerForKey:@"ballColour"];
    if (ballColour == 0) {
        _ball = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(10,10)];
        _ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
        _ball.physicsBody.dynamic = YES;
        _ball.physicsBody.usesPreciseCollisionDetection = YES;
        _ball.physicsBody.categoryBitMask = ballCategory;
        _ball.physicsBody.contactTestBitMask = bricksCategory;
        _ball.name = @"ball";
        _ball.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame));
        [self addChild:_ball];
    } else if (ballColour == 1) {
        _ball = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(10,10)];
        _ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
        _ball.physicsBody.dynamic = YES;
        _ball.physicsBody.usesPreciseCollisionDetection = YES;
        _ball.physicsBody.categoryBitMask = ballCategory;
        _ball.physicsBody.contactTestBitMask = bricksCategory;
        _ball.name = @"ball";
        _ball.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame));
        [self addChild:_ball];
    }
       return _ball;
}
-(void)addSafeGuards {
    //Safeguards (Prevents game from breaking due to ball physics
    SKSpriteNode *safeGuard = [[SKSpriteNode alloc] initWithColor:nil size:CGSizeMake(CGRectGetWidth(self.frame),10)];
    safeGuard.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMinY(self.frame)-10);
    safeGuard.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:safeGuard.size];
    safeGuard.physicsBody.dynamic = NO;
    safeGuard.name = @"safeGuard";
    [self addChild:safeGuard]; // Prevents breaking game if you go below the boundry
    SKSpriteNode *safeGuardLeftWall = [[SKSpriteNode alloc] initWithColor:nil size:CGSizeMake(10,CGRectGetHeight(self.frame))];
    safeGuardLeftWall.position = CGPointMake(CGRectGetMinX(self.frame),CGRectGetMidY(self.frame));
    safeGuardLeftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:safeGuardLeftWall.size];
    safeGuardLeftWall.physicsBody.dynamic = NO;
    safeGuardLeftWall.name = @"safeGuardLeft";
    [self addChild:safeGuardLeftWall]; // Prevents breaking game if the ball falls out of the wall
    SKSpriteNode *safeGuardRightWall = [[SKSpriteNode alloc] initWithColor:nil size:CGSizeMake(10,CGRectGetHeight(self.frame))];
    safeGuardRightWall.position = CGPointMake(CGRectGetMaxX(self.frame),CGRectGetMidY(self.frame));
    safeGuardRightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:safeGuardRightWall.size];
    safeGuardRightWall.physicsBody.dynamic = NO;
    safeGuardRightWall.name = @"safeGuardRight";
    [self addChild:safeGuardRightWall]; // Prevents breaking game if the ball falls out of the wall
}
- (void)addControls {
    // SpriteNodes for Controlling the game
    SKSpriteNode *leftSide = [[SKSpriteNode alloc] initWithColor:nil size:CGSizeMake(CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.frame))];
    leftSide.position = CGPointMake(CGRectGetMidX(self.frame)/2,CGRectGetMidY(self.frame));
    leftSide.name = @"leftSide";
    [self addChild:leftSide];
    SKSpriteNode *rightSide = [[SKSpriteNode alloc] initWithColor:nil size:CGSizeMake(CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.frame))];
    rightSide.position = CGPointMake(CGRectGetMidX(self.frame)+CGRectGetMidX(self.frame)/2,CGRectGetMidY(self.frame));
    rightSide.name = @"rightSide";
    [self addChild:rightSide];
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // constantly check score
    [self runAction:[SKAction performSelector:@selector(scoreCounter) onTarget:self]];
    // Game Over Checker
    if (_gameStarted == YES && _gameOver == NO && (_ball.position.y >= CGRectGetMaxY(self.frame)+1 || _ball.position.y <= CGRectGetMinY(self.frame)+11)) {
        [self gameOverMethod];
    };
    // Background Changer
    SKNode *background = [self childNodeWithName:@"background"];
    if (_shouldIChangeColour == YES) {
        [background runAction:[SKAction performSelector:@selector(changeColour) onTarget:self]];
        _shouldIChangeColour = NO;
    };
}
-(void)changeColour { //Changes Colour of the backround
    int durationTime;
    if (_blendFactor == 0.5) {
        _blendFactor = 0.0;
        durationTime = 5;
    } else {
        _blendFactor += 0.1;
        durationTime = 5;
    }
    SKNode *background = [self childNodeWithName:@"background"];
    [background runAction:[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:_blendFactor duration:durationTime]];
}
-(void)gameOverMethod{ //Ends the game and shows the player their score
    NSLog(@"Currency: %lu",_currency);
    _gameOver = YES; // End the game
    SKNode *instructions = [self childNodeWithName:@"instructions"];
    SKNode *gameTitle = [self childNodeWithName:@"gameTitle"];
    SKNode *gt_gameSubTitle = [self childNodeWithName:@"gt_gameSubTitle"];
    [instructions removeFromParent];
    [gameTitle removeFromParent];
    [gt_gameSubTitle removeFromParent];
    [_ball removeFromParent]; // Remove the ball
    [_platforms removeFromParent]; // Remove platforms
    [self saveUserProfile]; // Save Score
    unsigned long bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"SC_bestScore"]; // Get HighScore
    [self reportScore:bestScore]; // Send Score to Game Center
    // Medal Sprite
    SKSpriteNode *medal = [SKSpriteNode spriteNodeWithImageNamed:@"normalMedal"];
    medal.name = @"medal";
    medal.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-105);
    medal.xScale = 0.001f;
    medal.yScale = 0.001f;
    [self addChild:medal];
    // Gameover screen pop up
    SKSpriteNode *gameOverScreen = [SKSpriteNode spriteNodeWithImageNamed:@"gameOverScreen"];
    gameOverScreen.name = @"GG_gameOverScreen";
    gameOverScreen.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMidY(self.frame)));
    gameOverScreen.zPosition = 20;
    [self addChild:gameOverScreen];
    // Scoreboard score variables
    unsigned long highscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"SC_bestScore"];
    NSString *highscoreString = [NSString stringWithFormat:@"High Score: %lu",highscore];
    NSString *scoreString = [NSString stringWithFormat:@"Score: %d",_scoreNumber];
    // Titles
    SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithImageNamed:@"gameOver"];
    gameOver.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+75);
    gameOver.name = @"GG_title";
    gameOver.zPosition = 21;
    [self addChild:gameOver];
    
    [self labelText:scoreString labelName:@"GG_scoreTitle" xPosition:0 yPosition:0 fontSize:30];
    [self labelText:highscoreString labelName:@"GG_highScoreTitle" xPosition:0 yPosition:-25 fontSize:20];
    
    SKNode *scoreTitle = [self childNodeWithName:@"scoreTitle"];
    SKAction *removeScoreLabel = [SKAction sequence:@[ // Adds "bounce" effect to score then removes from view
                                                      [SKAction moveToY:(420) duration:0.4],
                                                      [SKAction moveToY:(CGRectGetMaxY(self.frame)) duration:0.3],
                                                      [SKAction removeFromParent]
                                                      ]];
    [scoreTitle runAction:removeScoreLabel completion:^(void){
        //Show Play Again and Main Menu buttons after the score hides, then load the Medal if awarded
        SKSpriteNode *playAgain = [SKSpriteNode spriteNodeWithImageNamed:@"play_icon"];
        playAgain.position = CGPointMake(CGRectGetMidX(self.frame)+50, CGRectGetMidY(self.frame)-150);
        playAgain.name = @"GG_playAgainButton";
        playAgain.zPosition = 21;
        [self addChild:playAgain];
        SKSpriteNode *backToMenu = [SKSpriteNode spriteNodeWithImageNamed:@"backToMenu_icon"];
        backToMenu.position = CGPointMake(CGRectGetMidX(self.frame)-50, CGRectGetMidY(self.frame)-150);
        backToMenu.name = @"GG_mainMenuButton";
        backToMenu.zPosition = 21;
        [self addChild:backToMenu];
        // Medals (Bronze, Silver, Gold, Platinum)
        
        SKAction *MedalMovement = [SKAction sequence:@[
                                                       [SKAction scaleTo:1.0 duration:0.5],
                                                       ]];
        SKAction *bronzeMedalMovement = [SKAction sequence:@[
                                                             [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:0.4 duration:0.0],
                                                             [SKAction scaleTo:1.0 duration:0.5],
                                                             ]];
        SKAction *silverMedalMovement = [SKAction sequence:@[
                                                             [SKAction colorizeWithColor:[SKColor lightGrayColor] colorBlendFactor:1 duration:0.0],
                                                             [SKAction scaleTo:1.0 duration:0.5],
                                                             ]];
        SKAction *goldMedalMovement = [SKAction sequence:@[
                                                           [SKAction colorizeWithColor:[SKColor yellowColor] colorBlendFactor:0.8 duration:0.0],
                                                           [SKAction scaleTo:1.0 duration:0.5],
                                                           ]];
        // Scores required for medals
        if (_scoreNumber <= 19) { // Bronze
            [self labelText:@"No Medal This Time" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
        } else if (_scoreNumber >= 20 && _scoreNumber <= 39) {
            [self labelText:@"Bronze Medal Awarded!" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
            [medal runAction:bronzeMedalMovement completion:^{
                medal.name = @"GG_medal";
            }];
        } else if (_scoreNumber >= 40 && _scoreNumber <= 89) { // Silver
            [self labelText:@"Silver Medal Awarded!" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
            [medal runAction:silverMedalMovement completion:^{
                medal.name = @"GG_medal";
            }];
        } else if (_scoreNumber >= 90 && _scoreNumber <= 149) { // Gold
            [self labelText:@"Gold Medal Awarded!" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
            [medal runAction:goldMedalMovement completion:^{
                medal.name = @"GG_medal";
            }];
        } else if (_scoreNumber >= 150) { // Platinum
            [self labelText:@"Platinum Medal Awarded!" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
            [medal runAction:MedalMovement completion:^{
                medal.name = @"GG_medal";
            }];
        }
    }];

}
// Method for making menu buttons
-(SKLabelNode *) labelText:(NSString *)labelText labelName:(NSString*)labelName xPosition:(int)positionOfX yPosition:(int)positionOfY fontSize:(int)fontSize {
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    label.text = labelText;
    label.fontSize = fontSize;
    label.position = CGPointMake(CGRectGetMidX(self.frame)+positionOfX, CGRectGetMidY(self.frame)+positionOfY);
    label.name = labelName;
    label.zPosition = 21;
    [self addChild:label];
    return label;
}
- (void)saveUserProfile{ // Save scores to NSUserDefaults profile
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    unsigned long bestScore = [userDefaults integerForKey:@"SC_bestScore"]; // Get HighScore
    // Compare if the current score is more than the previous high score
    if (self.scoreNumber > bestScore) {
        [userDefaults setInteger:self.scoreNumber forKey:@"SC_bestScore"]; // Set Highscores
    }
    [userDefaults setInteger:_currency forKey:@"gameCurrency"]; // Set gameCurrency
    [userDefaults synchronize]; // Saves scores to user profile (NOT GAMECENTER)
}
-(void)reportScore:(NSInteger ) highScore
{
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore *scoreReporter = [[GKScore alloc]  initWithLeaderboardIdentifier:@"sc_Leaderboard" forPlayer:[GKLocalPlayer localPlayer].playerID];
        scoreReporter.value = highScore;
        NSLog(@"Score reporter value: %@", scoreReporter);
        [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error");
                // handle the reporting error
            }
            
        }];
    }
}
-(void)didBeginContact:(SKPhysicsContact *)contact {
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    
    if (collision == (ballCategory | bricksCategory)) {
        [self runAction:[SKAction playSoundFileNamed:@"thud.m4a" waitForCompletion:NO]];
    }
    
    if (collision == (ballCategory | powersCategory)) {
        _currency +=1;
        NSLog(@"Got 1 coin, now at %lu currency",_currency);
        SKNode *powerUp = [_platforms childNodeWithName:@"powerUp"];
        [powerUp removeFromParent];
    }
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    // Controls
    // Variables we need to setup for both controls.
    float leftSideOfScreen = CGRectGetMinX(self.frame);
    float rightSideOfScreen = CGRectGetMaxX(self.frame);
    // Left Side Controls: Tap left side of the screen
    SKNode *leftSide = [self childNodeWithName:@"leftSide"]; //Import the leftSide node
    if ([leftSide containsPoint:location]) { // if leftSide node is touched
        SKAction *actionMove = [SKAction moveToX:(_ball.position.x)-35 duration:0.15]; // move the ball left
        [_ball runAction:actionMove completion:^{
            if (_ball.position.x < leftSideOfScreen) { // If the ball goes off the leftside of the screen
                SKAction *actionMoveLeftToRight = [SKAction sequence:@[
                                                                       [SKAction fadeOutWithDuration:0], // fade out ball
                                                                       [SKAction moveToX:(rightSideOfScreen)-5 duration:0], // move to rightSide
                                                                       [SKAction fadeInWithDuration:0] // fade in ball
                                                                       ]];
                [_ball runAction:actionMoveLeftToRight];
            }
        }];
    }
    // Right Side Controls: Tap right side of the screen
    SKNode *rightSide = [self childNodeWithName:@"rightSide"]; //Import the rightSide node
    if ([rightSide containsPoint:location]) { // if rightSide node is touched
        SKAction *actionMove = [SKAction moveToX:(_ball.position.x)+35 duration:0.15]; // move the ball right
        [_ball runAction:actionMove completion:^{
            if (_ball.position.x > rightSideOfScreen) { // If the ball goes off the rightside of the screen
                SKAction *actionMoveRightToLeft = [SKAction sequence:@[
                                                                       //[SKAction fadeOutWithDuration:0], // fade out ball
                                                                       [SKAction moveToX:(leftSideOfScreen)+5 duration:0], // move to leftSide
                                                                       //[SKAction fadeInWithDuration:0] // fade in ball
                                                                       ]];
                [_ball runAction:actionMoveRightToLeft];
            }
        }];
    }
    // END OF CONTROLS CODE
    SKNode *mainMenuButton = [self childNodeWithName:@"GG_mainMenuButton"];
    if ([mainMenuButton containsPoint:location])
    {
        [mainMenuButton runAction:[SKAction fadeOutWithDuration:0.2] completion:^{
            //Add physics to all nodes on the gameover screen, then make them fall, and then reload the game.
            [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SKNode *node = (SKNode *)obj;
                if ([[node.name substringWithRange:NSMakeRange(0, 3)] isEqual: @"GG_"]) {
                    
                    SKNode *safeGuard = [self childNodeWithName:@"safeGuard"];
                    [safeGuard removeFromParent];
                    
                    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
                    node.physicsBody.dynamic = YES;
                    SKAction *moveSequence = [SKAction sequence:@[
                                                                  [SKAction moveToY:CGRectGetMinY(self.frame)-100 duration:0.45],
                                                                  [SKAction waitForDuration:0.2],
                                                                  [SKAction removeFromParent]
                                                                  ]];
                    [node runAction:moveSequence completion:^{
                        SKScene *msMySceneLoad = [[msMyScene alloc] initWithSize:self.size];
                        [self.view presentScene:msMySceneLoad];
                    }];
                }
            }];
        }];
    }
    SKNode *playAgainButton = [self childNodeWithName:@"GG_playAgainButton"];
    if ([playAgainButton containsPoint:location])
    {
        [playAgainButton runAction:[SKAction fadeOutWithDuration:0.2] completion:^{
            //Add physics to all nodes on the gameover screen, then make them fall, and then reload the game.
            [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SKNode *node = (SKNode *)obj;
                if ([[node.name substringWithRange:NSMakeRange(0, 3)] isEqual: @"GG_"]) {
                    
                    SKNode *safeGuard = [self childNodeWithName:@"safeGuard"];
                    [safeGuard removeFromParent];
                    
                    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
                    node.physicsBody.dynamic = YES;
                    SKAction *moveSequence = [SKAction sequence:@[
                                                                  [SKAction moveToY:CGRectGetMinY(self.frame)-100 duration:0.45],
                                                                  [SKAction waitForDuration:0.2],
                                                                  [SKAction removeFromParent]
                                                                  ]];
                    [node runAction:moveSequence completion:^{
                        SKScene *msGameSceneLoad = [[msGameScene alloc] initWithSize:self.size];
                        [self.view presentScene:msGameSceneLoad];
                    }];
                }
            }];
        }];
    }
}
@end
