//
//  MAMyScene.m
//  RunAway
//
//  Created by Marlon Andrade on 12/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAMyScene.h"

#import "MAConstants.h"
#import "MAGameLayer.h"
#import "MAMonster.h"
#import "MAPlayer.h"
#import "MAVector.h"

typedef enum {
    MAMonsterSpawnPositionTop = 0,
    MAMonsterSpawnPositionLeft,
    MAMonsterSpawnPositionBottom,
    MAMonsterSpawnPositionRight
} MAMonsterSpawnPosition;

typedef enum {
    MAGameStateInitialScreen = 0,
    MAGameStatePlaying,
    MAGameStateJustLost,
    MAGameStateGameOver
} MAGameState;

@interface MAMyScene() <SKPhysicsContactDelegate>

@property (nonatomic, assign) MAGameState state;

@property (nonatomic, strong) SKNode *initialScreenLayer;
@property (nonatomic, strong) SKNode *hudLayer;
@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *gameOverLayer;

@property (nonatomic, strong) MAPlayer *player;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *highScoreLabel;
@property (nonatomic, strong) SKNode *touchScreenToRestartLabel;

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;

@property (nonatomic, assign) CFTimeInterval lastUpdateTime;

@end

@implementation MAMyScene

#pragma mark - Getter

- (SKNode *)initialScreenLayer {
    if (!_initialScreenLayer) {
        _initialScreenLayer = [SKNode node];
        _initialScreenLayer.alpha = 0.f;
        _initialScreenLayer.position = CGPointMake(CGRectGetMidX(self.frame),
                                                   CGRectGetMidY(self.frame));

        SKNode *runAwayLabel = [self _createRunAwayLabel];
        runAwayLabel.position = CGPointMake(0.f, 20.f);
        [_initialScreenLayer addChild:runAwayLabel];

        SKNode *touchToStartLabel = [self _createTouchToStartLabel];
        touchToStartLabel.position = CGPointMake(0.f, -30.f);
        [_initialScreenLayer addChild:touchToStartLabel];
    }

    return _initialScreenLayer;
}

- (SKNode *)hudLayer {
    if (!_hudLayer) {
        _hudLayer = [SKNode node];
        _hudLayer.alpha = 0.f;

        self.scoreLabel = [self _createScoreLabel];
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                               CGRectGetMaxY(self.frame) - 50.f);
        [_hudLayer addChild:self.scoreLabel];

        SKNode *highScoreDescription = [self _createHighScoreDescriptionLabel];
        highScoreDescription.position = CGPointMake(CGRectGetMidX(self.frame) + 80.f,
                                                    CGRectGetMaxY(self.frame) - 50.f);
        [_hudLayer addChild:highScoreDescription];

        self.highScoreLabel = [self _createHighScoreLabel];
        self.highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 130.f,
                                                   CGRectGetMaxY(self.frame) - 50.f);
        [_hudLayer addChild:self.highScoreLabel];
    }

    return _hudLayer;
}

- (SKNode *)gameLayer {
    if (!_gameLayer) {
        _gameLayer = [MAGameLayer node];
        _gameLayer.alpha = 0.f;

        self.player = [MAPlayer player];
        [_gameLayer addChild:self.player];
    }
    return _gameLayer;
}

- (SKNode *)gameOverLayer {
    if (!_gameOverLayer) {
        _gameOverLayer = [SKNode node];
        _gameOverLayer.alpha = 0.f;

        SKNode *gameOverLabel = [self _createGameOverLabel];
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMidY(self.frame) + 20.f);
        [_gameOverLayer addChild:gameOverLabel];

        self.touchScreenToRestartLabel = [self _createTouchToRestartLabel];
        self.touchScreenToRestartLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                                 CGRectGetMidY(self.frame) - 30.f);
        [_gameOverLayer addChild:self.touchScreenToRestartLabel];
    }

    return _gameOverLayer;
}

- (int)highScore {
    return [[NSUserDefaults standardUserDefaults] integerForKey:HIGH_SCORE_KEY];
}

#pragma mark - Setter

- (void)setState:(MAGameState)state {
    _state = state;

    switch (state) {
        case MAGameStateInitialScreen:
            [self _adjustStateForInitialScreen];
            break;
        case MAGameStatePlaying:
            [self _adjustStateForPlaying];
            break;
        case MAGameStateJustLost:
            [self _adjustStateForJustLost];
            break;
        case MAGameStateGameOver:
            [self _adjustStateForGameOver];
            break;
    }
}

- (void)setScore:(int)score {
    _score = score;

    self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];

    if (self.score > self.highScore) {
        self.highScore = self.score;
    }
}

- (void)setHighScore:(int)highScore {
    [[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:HIGH_SCORE_KEY];
    self.highScoreLabel.text = [NSString stringWithFormat:@"%d", highScore];
}

#pragma mark - Designated Initializer

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];

    if (self) {
        self.backgroundColor = [SKColor colorWithWhite:0.2f alpha:1.f];

        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0.f, 0.f);

        [self addChild:self.initialScreenLayer];
        [self addChild:self.hudLayer];
        [self addChild:self.gameLayer];
        [self addChild:self.gameOverLayer];

        self.state = MAGameStateInitialScreen;
    }

    return self;
}

#pragma mark - UIResponder Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.state == MAGameStateInitialScreen || self.state == MAGameStateGameOver) {
        self.state = MAGameStatePlaying;
    } else if (self.state == MAGameStatePlaying) {
        for (UITouch *touch in touches) {
            [self _adjustPlayerDirection:[touch locationInNode:self]];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.state == MAGameStatePlaying) {
        for (UITouch *touch in touches) {
            [self _adjustPlayerDirection:[touch locationInNode:self]];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.player.direction = [MAVector vectorZero];
}

#pragma mark - SKScene Methods

- (void)update:(CFTimeInterval)currentTime {
    CFTimeInterval deltaTime = currentTime - self.lastUpdateTime;

    CGFloat deltaX = self.player.direction.x * self.player.moveSpeed * deltaTime;
    CGFloat deltaY = self.player.direction.y * self.player.moveSpeed * deltaTime;

    CGFloat x = self.player.position.x + deltaX;
    CGFloat y = self.player.position.y + deltaY;

    x = MAX(x, CGRectGetMinX(self.frame) + (self.player.size.width / 4.f));
    x = MIN(x, CGRectGetMaxX(self.frame) - (self.player.size.width / 4.f));
    y = MAX(y, CGRectGetMinY(self.frame) + (self.player.size.height / 4.f));
    y = MIN(y, CGRectGetMaxY(self.frame) - (self.player.size.height / 4.f));

    self.player.position = CGPointMake(x, y);

    self.lastUpdateTime = currentTime;
}

#pragma mark - SKNode Creation

- (SKNode *)_createRunAwayLabel {
    SKLabelNode *runAway = [SKLabelNode labelNodeWithFontNamed:GAME_DEFAULT_FONT];
    runAway.fontSize = 50.f;
    runAway.text = @"Run Away!";

    return runAway;
}

- (SKNode *)_createTouchToStartLabel {
    return [self _createBlinkingLabelWithText:@"Touch screen to start"];
}

- (SKLabelNode *)_createScoreLabel {
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:GAME_DEFAULT_FONT];
    scoreLabel.fontColor = [SKColor whiteColor];
    scoreLabel.fontSize = 30.f;

    return scoreLabel;
}

- (SKNode *)_createHighScoreDescriptionLabel {
    SKLabelNode *highScoreDescription = [SKLabelNode labelNodeWithFontNamed:GAME_DEFAULT_FONT];
    highScoreDescription.fontColor = [SKColor colorWithWhite:0.7f alpha:1.f];
    highScoreDescription.fontSize = 12.f;
    highScoreDescription.text = @"Highscore:";

    return highScoreDescription;
}

- (SKLabelNode *)_createHighScoreLabel {
    self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:GAME_DEFAULT_FONT];
    self.highScoreLabel.fontColor = [SKColor whiteColor];
    self.highScoreLabel.fontSize = 30.f;
    self.highScoreLabel.text = [NSString stringWithFormat:@"%d", self.highScore];

    return self.highScoreLabel;
}

- (SKNode *)_createGameOverLabel {
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:GAME_DEFAULT_FONT];
    gameOverLabel.fontSize = 45.f;
    gameOverLabel.text = @"Game Over";

    return gameOverLabel;
}

- (SKNode *)_createTouchToRestartLabel {
    return [self _createBlinkingLabelWithText:@"Touch screen to restart"];
}

- (SKNode *)_createBlinkingLabelWithText:(NSString *)text {
    SKLabelNode *blinkLabel = [SKLabelNode labelNodeWithFontNamed:GAME_DEFAULT_FONT];
    blinkLabel.fontSize = 16.f;
    blinkLabel.text = text;

    SKAction *blinkAction = [SKAction sequence:@[
        [SKAction fadeOutWithDuration:2.f],
        [SKAction fadeInWithDuration:2.f],
    ]];

    [blinkLabel runAction:[SKAction repeatActionForever:blinkAction]];

    return blinkLabel;
}

#pragma mark - Private Interface

- (void)_spawnMonster {
    self.score++;
    MAMonsterSpawnPosition spawnPosition = arc4random_uniform(4);

    CGFloat x;
    CGFloat y;

    MAMonster *monster = [MAMonster monster];

    CGFloat angle = drand48() - 0.5f;
    CGFloat destinationX;
    CGFloat destinationY;

    switch (spawnPosition) {
        case MAMonsterSpawnPositionTop:
            x = arc4random_uniform(self.frame.size.width);
            y = self.frame.size.height + monster.size.height;
            destinationX = tanf(angle) * self.frame.size.height + (monster.size.height * 2);
            destinationY = - monster.size.height;
            break;
        case MAMonsterSpawnPositionLeft:
            x = - monster.size.width;
            y = arc4random_uniform(self.frame.size.height);
            destinationX = self.frame.size.width + monster.size.width;
            destinationY = tanf(angle) * self.frame.size.width + (monster.size.width * 2);
            break;
        case MAMonsterSpawnPositionBottom:
            x = arc4random_uniform(self.frame.size.width);
            y = - monster.size.height;
            destinationX = tanf(angle) * self.frame.size.height + (monster.size.height * 2);
            destinationY = self.frame.size.height + monster.size.height;
            break;
        case MAMonsterSpawnPositionRight:
            x = self.frame.size.width + monster.size.width;
            y = arc4random_uniform(self.frame.size.height);
            destinationX = - monster.size.width;
            destinationY = tanf(angle) * self.frame.size.width + (monster.size.width * 2);
            break;
    }

    monster.position = CGPointMake(x, y);
    CGPoint destination = CGPointMake(destinationX, destinationY);

    [self.gameLayer addChild:monster];

    CGFloat duration = arc4random_uniform(3) + 2;
    [monster runAction:[SKAction sequence:@[
        [SKAction moveTo:destination duration:duration],
        [SKAction removeFromParent]
    ]]];
}

- (void)_adjustPlayerDirection:(CGPoint)location {
    self.player.direction = [[MAVector vectorWithX:location.x - self.player.position.x
                                                 Y:location.y - self.player.position.y] normalize];
}

- (void)_changeToGameOver {
    self.state = MAGameStateGameOver;
}

#pragma mark - State Change

- (void)_adjustStateForInitialScreen {
    self.initialScreenLayer.alpha = 1.f;
}

- (void)_adjustStateForPlaying {
    if (self.initialScreenLayer.alpha) {
        [self.initialScreenLayer runAction:[SKAction fadeOutWithDuration:0.3f]];
    }

    if (self.gameOverLayer.alpha) {
        [self.gameOverLayer runAction:[SKAction fadeOutWithDuration:0.3f]];
    }

    if (!self.gameLayer.alpha) {
        [self.gameLayer runAction:[SKAction fadeInWithDuration:0.3f]];
    }

    if (!self.hudLayer.alpha) {
        [self.hudLayer runAction:[SKAction fadeInWithDuration:0.3f]];
    }

    self.player.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
    self.score = 0;

    SKAction *spawnMonster = [SKAction sequence:@[
        [SKAction performSelector:@selector(_spawnMonster) onTarget:self],
        [SKAction waitForDuration:0.4f]
    ]];
    [self runAction:[SKAction repeatActionForever:spawnMonster]];
}

- (void)_adjustStateForJustLost {
    [self.touchScreenToRestartLabel removeFromParent];

    if (!self.gameOverLayer.alpha) {
        [self.gameOverLayer runAction:[SKAction fadeInWithDuration:0.3f]];
    }

    if (self.gameLayer.alpha) {
        [self.gameLayer runAction:[SKAction fadeOutWithDuration:0.3f]];
    }

    [self removeAllActions];
}

- (void)_adjustStateForGameOver {
    self.touchScreenToRestartLabel.alpha = 0.f;
    [self.gameOverLayer addChild:self.touchScreenToRestartLabel];
}

#pragma mark - SKPhysicsContactDelegate Methods

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (self.state == MAGameStatePlaying) {
        self.state = MAGameStateJustLost;
        [self performSelector:@selector(_changeToGameOver) withObject:nil afterDelay:1.5f];
    }
}

@end
