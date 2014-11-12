//
//  msTimeAttackGameScene.m
//  BlockDrop
//
//  Created by Madison Spry on 27/08/2014.
//  Copyright (c) 2014 Madison Spry. All rights reserved.
//

#import "msTimeAttackGameScene.h"
#import "msMyScene.h"

static const uint32_t ballCategory = 0x1 << 0;
static const uint32_t bricksCatergory = 0x1 << 1;

@interface msTimeAttackGameScene()
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
@property BOOL passPlatform;
@property int scoreNumber;
@property int timeLeft;
@property double blendFactor;
@property float platformMovementDuration;
@property CGFloat distanceToMove;
@property int platformStartingPosition;
@property SKAction* setupPosition;
@property BOOL hasTimeStarted;
@end

@implementation msTimeAttackGameScene
-(void)didMoveToView:(SKView *)view { //Checks if the view has loaded
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}
-(void)createSceneContents { //Create Scene Contents
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
    //Platform
    _platformMovementDuration = 4;
    [self runAction:[SKAction sequence:@[
                                          [SKAction performSelector:@selector(addPlatform) onTarget:self],
                                          [SKAction waitForDuration:0.5]
                                          ]]];
    // Score
    NSString* scoreString = @"0"; // Sets starting score to 0
    [self score:scoreString]; // Adds Score Counter
    // Time String
    SKLabelNode *dummyTime = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    dummyTime.text = @"15";
    dummyTime.fontSize = 30;
    dummyTime.position = CGPointMake(CGRectGetMidX(self.frame)-50, CGRectGetMidY(self.frame)+150);
    dummyTime.name = @"dummyTime";
    [self addChild:dummyTime];
    // Show game instructions
    //gameTitle logo
    SKSpriteNode *gameTitle = [SKSpriteNode spriteNodeWithImageNamed:@"timeAttackLogo"];
    gameTitle.name = @"gt_gameTitle";
    gameTitle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+95);
    [self addChild:gameTitle];
    //Phrases
    NSString* gameSubTitleText;
    SKLabelNode *gameSubTitle = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    switch (arc4random_uniform(6)+1) {
        case 1:
            gameSubTitleText = @"Fall as fast as you can!";
            break;
        case 2:
            gameSubTitleText = @"Try to get a Platinum Medal!";
            break;
        case 3:
            gameSubTitleText = @"Time Gates add 5 seconds to your time!";
            break;
        case 4:
            gameSubTitleText = @"Every 20 points is a Time Gate!";
            break;
        case 5:
            gameSubTitleText = @"Jump from wall to wall!";
            break;
        case 6:
            gameSubTitleText = @"Does it ever end!?";
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
    SKLabelNode *gameSubTitle2 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    gameSubTitle2.text = @"Fall Down to Start";
    gameSubTitle2.fontColor = [UIColor blackColor];
    gameSubTitle2.fontSize = 15;
    gameSubTitle2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+40);
    gameSubTitle2.name = @"gt_gameSubTitle";
    [self addChild:gameSubTitle2];
    SKSpriteNode *instructions = [SKSpriteNode spriteNodeWithImageNamed:@"instructions"];
    instructions.name = @"gt_instructions";
    instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    instructions.zPosition = 100;
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
}
-(void)addPlatform {
    _platformTexture1 = [SKTexture textureWithImageNamed:@"platform1"];
    _platformTexture1.filteringMode = SKTextureFilteringNearest;
    _platformTexture2 = [SKTexture textureWithImageNamed:@"platform2"];
    _platformTexture2.filteringMode = SKTextureFilteringNearest;
    _platformStartingPosition = CGRectGetMinY(self.frame);
    _setupPosition = [SKAction moveToY:_platformStartingPosition duration:0];
    _distanceToMove = (CGRectGetMidY(self.frame)/2 - _platformTexture1.size.height/2);
    SKAction* movePipes = [SKAction moveByX:0 y:_distanceToMove duration:0.25];
    _movePipesAndRemove = [SKAction sequence:@[movePipes]];
    SKAction* spawn;
    if ( _lastWasPlatform == YES && _spawnedFirstPlatform == YES) {
        spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
        _lastWasPlatform = NO;
    } else if (_lastWasPlatform == NO && _spawnedFirstPlatform == YES) {
        spawn = [SKAction performSelector:@selector(spawnPlatforms) onTarget:self];
        _lastWasPlatform = YES;
    } else if (_spawnedFirstPlatform == NO) {
        spawn = [SKAction performSelector:@selector(spawnFirstPlatform) onTarget:self];
    }
    [self runAction:spawn];
}
-(void)spawnFirstPlatform { // Always starts game with platform in the middle
    SKSpriteNode *firstPlatform = [SKSpriteNode spriteNodeWithTexture:_platformTexture1];
    firstPlatform.position = CGPointMake(CGRectGetMidX(self.frame),_platformStartingPosition);
    firstPlatform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:firstPlatform.size];
    firstPlatform.physicsBody.dynamic = NO;
    firstPlatform.physicsBody.categoryBitMask = bricksCatergory;
    firstPlatform.physicsBody.contactTestBitMask = ballCategory;
    firstPlatform.name = @"platform";
    [firstPlatform setScale:2.25];
    [_platforms addChild:firstPlatform];
    _spawnedFirstPlatform = YES;
    _lastWasPlatform = YES;
    [firstPlatform runAction:_setupPosition];
    SKAction* movePlatforms = [SKAction moveByX:0 y:(_distanceToMove*2) duration:0.5];
    [firstPlatform runAction:movePlatforms];
    [_platforms runAction:[SKAction sequence:@[
                                                  [SKAction waitForDuration:0.25],
                                                  [SKAction performSelector:@selector(addPlatform) onTarget:self]
                                                  ]]];
}
-(void)spawnPipes {
    SKNode* pipePair = [SKNode node];
    pipePair.position = CGPointMake( 0, CGRectGetMinY(self.frame) - _platformTexture1.size.height/2);
    pipePair.zPosition = 50;
    pipePair.name = @"platform";

    CGFloat horizontalDoubleGap = 100;
    CGFloat x = arc4random_uniform(150)+1;
    
    SKSpriteNode* platform1 = [SKSpriteNode spriteNodeWithTexture:_platformTexture1];
    [platform1 setScale:2.25];
    platform1.position = CGPointMake(x, _platformStartingPosition);
    platform1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform1.size];
    platform1.physicsBody.dynamic = NO;
    platform1.physicsBody.categoryBitMask = bricksCatergory;
    platform1.physicsBody.contactTestBitMask = ballCategory;
    platform1.name = @"platform1";
    [pipePair addChild:platform1];
    
    SKSpriteNode* platform2 = [SKSpriteNode spriteNodeWithTexture:_platformTexture2];
    [platform2 setScale:2.25];
    platform2.position = CGPointMake(x + platform1.size.width + horizontalDoubleGap, _platformStartingPosition);
    platform2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform2.size];
    platform2.physicsBody.dynamic = NO;
    platform2.physicsBody.categoryBitMask = bricksCatergory;
    platform2.physicsBody.contactTestBitMask = ballCategory;
    platform2.name = @"platform2";
    [pipePair addChild:platform2];
    
    [pipePair runAction:_setupPosition];
    [pipePair runAction:_movePipesAndRemove];
    [_platforms addChild:pipePair];
}
-(void)spawnPlatforms {
    CGFloat widthGap = arc4random_uniform(CGRectGetMaxX(self.frame))+1;
    SKSpriteNode *platform = [SKSpriteNode spriteNodeWithTexture:_platformTexture1];
    platform.position = CGPointMake(widthGap,_platformStartingPosition);
    platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform.size];
    platform.physicsBody.dynamic = NO;
    platform.physicsBody.categoryBitMask = bricksCatergory;
    platform.physicsBody.contactTestBitMask = ballCategory;
    platform.name = @"platform";
    [platform setScale:2.25];
    [_platforms addChild:platform];
    [platform runAction:_setupPosition];
    [platform runAction: _movePipesAndRemove];
}
-(SKLabelNode *) time:(NSString*)timeString {
    SKLabelNode *timeTitle = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    timeTitle.text = timeString;
    timeTitle.fontSize = 30;
    timeTitle.position = CGPointMake(CGRectGetMidX(self.frame)-50, CGRectGetMidY(self.frame)+150);
    timeTitle.name = @"timeTitle";
    [self addChild:timeTitle];
    return timeTitle;
}
-(SKLabelNode *) score:(NSString*)scoreString {
    SKLabelNode *scoreTitle = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    scoreTitle.text = scoreString;
    scoreTitle.fontSize = 30;
    scoreTitle.position = CGPointMake(CGRectGetMidX(self.frame)+50, CGRectGetMidY(self.frame)+150);
    scoreTitle.name = @"scoreTitle";
    [self addChild:scoreTitle];
    return scoreTitle;
}
-(void)scoreCounter {
    SKNode *platform = [_platforms childNodeWithName:@"platform"];
    SKNode *scoreTitle = [self childNodeWithName:@"scoreTitle"];
    if ([platform.name isEqualToString:@"platform"] && _ball.position.y < platform.position.y && _gameOver == NO) {
        platform.name = nil;
        _scoreNumber++; //Increases Score
        [platform runAction:[SKAction sequence:@[
                                                 [SKAction moveByX:0 y:_distanceToMove duration:0.5],
                                                 ]]];
        SKNode *nextPlatform = [_platforms childNodeWithName:@"platform"];
        [nextPlatform runAction:[SKAction sequence:@[
                                                     [SKAction moveByX:0 y:_distanceToMove duration:0.25]
                                                     ]]];
        [_platforms runAction:[SKAction performSelector:@selector(addPlatform) onTarget:self]];
        [platform runAction:[SKAction sequence:@[
                                                 [SKAction repeatAction:_movePipesAndRemove count:2],
                                                 [SKAction removeFromParent]
                                                 ]]];
         if (_scoreNumber % 20 == 0 && (_timeLeft != 0)) {
             SKSpriteNode *timeGate = [SKSpriteNode spriteNodeWithImageNamed:@"timeGateLogo"];
             timeGate.name = @"timeGate";
             timeGate.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+95);
             [self addChild:timeGate];
             
             SKLabelNode *timeUp = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
             timeUp.text = @"+ 5 Seconds";
             timeUp.fontColor = [UIColor blackColor];
             timeUp.fontSize = 15;
             timeUp.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+60);
             timeUp.name = @"gt_fallLabel";
             [self addChild:timeUp];
             
             SKAction* removeTimeGate = [SKAction sequence:@[
                                                            [SKAction fadeOutWithDuration:0.75],
                                                            [SKAction removeFromParent]
                                                            ]];
             [timeGate runAction:removeTimeGate];
             [timeUp runAction:removeTimeGate];
             if  (_scoreNumber == 20) {
                 _timeLeft += 5;
             }
             if (_scoreNumber >= 40) {
                 _timeLeft += 5;
             }
            [self runAction:[SKAction playSoundFileNamed:@"score.m4a" waitForCompletion:NO]];
            SKNode *timeTitle = [self childNodeWithName:@"timeTitle"];
            NSString *timeString = [@(_timeLeft) stringValue];
            if (timeTitle.name != nil) {
                SKAction *removeScoreLabel = [SKAction sequence:@[
                                                                  [SKAction removeFromParent],
                                                                  [SKAction waitForDuration:0.1]
                                                                  ]];
                [timeTitle runAction:removeScoreLabel];
            }
            [self time:timeString];
        }
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
    _ball = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(10,10)];
    //SKSpriteNode *ballObject = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    _ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    _ball.physicsBody.dynamic = YES;
    _ball.physicsBody.usesPreciseCollisionDetection = YES;
    _ball.physicsBody.categoryBitMask = ballCategory;
    _ball.physicsBody.contactTestBitMask = bricksCatergory;
    _ball.name = @"ball";
    _ball.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame));
    [self addChild:_ball];
    return _ball;
}
-(void)addSafeGuards {
    //Safeguards (Prevents game from breaking due to ball physics)
    SKSpriteNode *safeGuard = [[SKSpriteNode alloc] initWithColor:nil size:CGSizeMake(CGRectGetWidth(self.frame),100)];
    safeGuard.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMidY(self.frame)-80));
    safeGuard.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:safeGuard.size];
    safeGuard.physicsBody.dynamic = NO;
    safeGuard.name = @"safeGuard";
    safeGuard.zPosition = -1;
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
- (void)subtractTime {
    _timeLeft--; // subtract one
    SKNode *timeTitle = [self childNodeWithName:@"timeTitle"];
    NSString *timeString = [@(_timeLeft) stringValue];
    if (_timeLeft > 0) {
        [timeTitle removeFromParent];
        [self time:timeString];
    }
    if (_timeLeft == 0) { // ignore until time is 0
        [self gameOverMethod];
    }
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // constantly check score
    [self runAction:[SKAction performSelector:@selector(scoreCounter) onTarget:self]];
    // Game Over Checker
    if (_gameStarted == YES && _gameOver == NO && (_ball.position.y >= CGRectGetMaxY(self.frame)+1)) {
        [self gameOverMethod];
    };
    if (_ball.position.y <= CGRectGetMinY(self.frame)+11) {
        [_ball runAction:[SKAction moveToY:(CGRectGetMidY(self.frame)+50) duration:0]];
    }
    // Background Changer
    SKNode *background = [self childNodeWithName:@"background"];
    if (_shouldIChangeColour == YES) {
        [background runAction:[SKAction performSelector:@selector(changeColour) onTarget:self]];
        _shouldIChangeColour = NO;
    };
    // Time Starter
    if (_scoreNumber > 0 && _hasTimeStarted == NO) {
        SKNode *dummyTime = [self childNodeWithName:@"dummyTime"];
        [dummyTime removeFromParent];
        // Timer
        _timeLeft = 15;
        NSString* timeString = [@(_timeLeft) stringValue];
        [self time:timeString];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f // start timer, run every second
                                                 target:self
                                               selector:@selector(subtractTime) // runs this each time
                                               userInfo:nil
                                                repeats:YES];
        [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SKNode *node = (SKNode *)obj;
            if ([[node.name substringWithRange:NSMakeRange(0, 3)] isEqual: @"gt_"]) {
                SKAction* removeNodes = [SKAction sequence:@[
                                    [SKAction fadeOutWithDuration:1],
                                    [SKAction removeFromParent]
                                    ]];
                [node runAction:removeNodes];
            }
        }];
        _hasTimeStarted = YES;
    }
}
-(void)changeColour { //Changes Colour of the background
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
    _gameOver = YES; // End the game
    [_ball removeFromParent]; // Remove the ball
    [_platforms removeFromParent]; // Remove platforms
    [timer invalidate]; // Stop the timer
    [self saveUserProfile]; // Save Score
    unsigned long bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"TA_bestScore"]; // Get HighScore
    [self reportScore:bestScore]; // Send Score to Game Center
    // Medal Sprite
    SKSpriteNode *medal = [SKSpriteNode spriteNodeWithImageNamed:@"timeAttackMedal"];
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
    unsigned long highscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"TA_bestScore"];
    NSString *highscoreString = [NSString stringWithFormat:@"High Score: %lu",highscore];
    unsigned long score = [[NSUserDefaults standardUserDefaults] integerForKey:@"TA_theScore"];
    NSString *scoreString = [NSString stringWithFormat:@"Score: %lu",score];
    // Titles
    SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithImageNamed:@"gameOver"];
    gameOver.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+75);
    gameOver.name = @"GG_title";
    gameOver.zPosition = 21;
    [self addChild:gameOver];
    
    [self labelText:scoreString labelName:@"GG_scoreTitle" xPosition:0 yPosition:0 fontSize:30];
    [self labelText:highscoreString labelName:@"GG_highScoreTitle" xPosition:0 yPosition:-25 fontSize:20];
    
    SKNode *timeTitle = [self childNodeWithName:@"timeTitle"];
    SKNode *scoreTitle = [self childNodeWithName:@"scoreTitle"];
    SKAction *removeScoreLabel = [SKAction sequence:@[ // Adds "bounce" effect to score then removes from view
                                                      [SKAction moveToY:(420) duration:0.4],
                                                      [SKAction moveToY:(CGRectGetMaxY(self.frame)) duration:0.3],
                                                      [SKAction removeFromParent]
                                                      ]];
    [timeTitle runAction:removeScoreLabel];
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
        if (score <= 39) { // No Medal
            [self labelText:@"No Medal This Time" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
        } else if (score >= 40 && score <= 79) { // Bronze
            [self labelText:@"Bronze Medal Awarded!" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
            [medal runAction:bronzeMedalMovement completion:^{
                medal.name = @"GG_medal";
            }];
        } else if (score >= 80 && score <= 119) { // Silver
            [self labelText:@"Silver Medal Awarded!" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
            [medal runAction:silverMedalMovement completion:^{
                medal.name = @"GG_medal";
            }];
        } else if (score >= 120 && score <= 159) { // Gold
            [self labelText:@"Gold Medal Awarded!" labelName:@"GG_medalTitle" xPosition:0 yPosition:-65 fontSize:15];
            [medal runAction:goldMedalMovement completion:^{
                medal.name = @"GG_medal";
            }];
        } else if (score >= 160) { // Platinum
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
    unsigned long bestScore = [userDefaults integerForKey:@"TA_bestScore"]; // Get HighScore
    int theScore = self.scoreNumber;
    [userDefaults setInteger:theScore forKey:@"TA_theScore"]; // Set theScore
    // Compare if the current score is more than the previous high score
    if (self.scoreNumber > bestScore) {
        [userDefaults setInteger:self.scoreNumber forKey:@"TA_bestScore"]; // Set Highscores
    }
    [userDefaults synchronize]; // Saves scores to user profile (NOT GAMECENTER)
}
-(void)reportScore:(NSInteger ) highScore
{
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore *scoreReporter = [[GKScore alloc]  initWithLeaderboardIdentifier:@"ta_leaderboard" forPlayer:[GKLocalPlayer localPlayer].playerID];
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
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    
    if (collision == (ballCategory | bricksCatergory))
    {
        [self runAction:[SKAction playSoundFileNamed:@"thud.m4a" waitForCompletion:NO]];
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
                                                                       [SKAction moveToX:(rightSideOfScreen)-1.5 duration:0], // move to rightSide
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
                                                                       [SKAction fadeOutWithDuration:0], // fade out ball
                                                                       [SKAction moveToX:(leftSideOfScreen)+1.5 duration:0], // move to leftSide
                                                                       [SKAction fadeInWithDuration:0] // fade in ball
                                                                       ]];
                [_ball runAction:actionMoveRightToLeft];
            }
        }];
    }
    //END OF CONTROLS CODE
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
                        SKScene *msGameSceneLoad = [[msTimeAttackGameScene alloc] initWithSize:self.size];
                        [self.view presentScene:msGameSceneLoad];
                    }];
                }
            }];
        }];
    }
}
@end
