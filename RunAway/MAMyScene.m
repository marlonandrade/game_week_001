//
//  MAMyScene.m
//  RunAway
//
//  Created by Marlon Andrade on 12/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAMyScene.h"

#import "MAConstants.h"
#import "MAMonster.h"
#import "MAPlayer.h"
#import "MAVector.h"

typedef enum {
    MAMonsterSpawnPositionTop = 0,
    MAMonsterSpawnPositionLeft,
    MAMonsterSpawnPositionBottom,
    MAMonsterSpawnPositionRight
} MAMonsterSpawnPosition;

@interface MAMyScene() <SKPhysicsContactDelegate>

@property (nonatomic, strong) MAPlayer *player;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *highScoreLabel;

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;

@property (nonatomic, assign, getter = isGameStarted) bool gameStarted;
@property (nonatomic, assign, getter = isGameOver) bool gameOver;

@property (nonatomic, assign) CFTimeInterval lastUpdateTime;

@end

@implementation MAMyScene

#pragma mark - Getter

- (int)highScore {
    return [[NSUserDefaults standardUserDefaults] integerForKey:HIGH_SCORE_KEY];
}

#pragma mark - Setter

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
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithWhite:0.2f alpha:1.f];

        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0.f, 0.f);

        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
        self.scoreLabel.fontColor = [SKColor whiteColor];
        self.scoreLabel.fontSize = 30.f;
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                               CGRectGetMaxY(self.frame) - 50.f);
        [self addChild:self.scoreLabel];

        SKLabelNode *highScoreDescription = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
        highScoreDescription.fontColor = [SKColor colorWithWhite:0.7f alpha:1.f];
        highScoreDescription.fontSize = 12.f;
        highScoreDescription.position = CGPointMake(CGRectGetMidX(self.frame) + 80.f,
                                                    CGRectGetMaxY(self.frame) - 50.f);
        highScoreDescription.text = @"Highscore:";

        [self addChild:highScoreDescription];


        self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
        self.highScoreLabel.fontColor = [SKColor whiteColor];
        self.highScoreLabel.fontSize = 30.f;
        self.highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 130.f,
                                                   CGRectGetMaxY(self.frame) - 50.f);
        self.highScoreLabel.text = [NSString stringWithFormat:@"%d", self.highScore];

        [self addChild:self.highScoreLabel];

        SKLabelNode *runAway = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
        runAway.name = @"run_away";
        runAway.fontSize = 50.f;
        runAway.text = @"Run Away!";
        runAway.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMidY(self.frame) + 20.f);
        [self addChild:runAway];

        SKLabelNode *tapToStart = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
        tapToStart.name = @"run_away_start";
        tapToStart.fontSize = 16.f;
        tapToStart.text = @"Tap screen to start";
        tapToStart.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame) - 30.f);
        [self addChild:tapToStart];

        SKAction *blinkAction = [SKAction sequence:@[
            [SKAction fadeOutWithDuration:2.f],
            [SKAction fadeInWithDuration:2.f],
        ]];

        [tapToStart runAction:[SKAction repeatActionForever:blinkAction]];
    }
    return self;
}

#pragma mark - UIResponder Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isGameStarted || self.isGameOver) {
        [self _resetGame];
    } else {
        for (UITouch *touch in touches) {
            [self _adjustPlayerDirection:[touch locationInNode:self]];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self _adjustPlayerDirection:[touch locationInNode:self]];
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

#pragma mark - Private Interface

- (void)_resetGame {
    self.gameStarted = YES;
    self.gameOver = NO;

    [[self childNodeWithName:@"run_away"] removeFromParent];
    [[self childNodeWithName:@"run_away_start"] removeFromParent];
    [[self childNodeWithName:@"game_over"] removeFromParent];
    [[self childNodeWithName:@"game_over_restart"] removeFromParent];

    self.player = [MAPlayer player];
    [self addChild:self.player];

    self.player.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
    self.score = 0;

    SKAction *spawnMonster = [SKAction sequence:@[
        [SKAction performSelector:@selector(_spawnMonster) onTarget:self],
        [SKAction waitForDuration:0.4f]
    ]];
    [self runAction:[SKAction repeatActionForever:spawnMonster]];
}

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

    [self addChild:monster];

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

- (void)_gameOver {
    [self removeAllActions];

    self.gameOver = YES;

    [[self childNodeWithName:PLAYER_NODE_NAME] runAction:[SKAction sequence:@[
        [SKAction removeFromParent]
    ]]];

    [self enumerateChildNodesWithName:MONSTER_NODE_NAME usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:[SKAction fadeOutWithDuration:1.f]];
        node.physicsBody = nil;
    }];

    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
    gameOverLabel.name = @"game_over";
    gameOverLabel.fontSize = 45.f;
    gameOverLabel.text = @"Game Over";
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + 20.f);
    [self addChild:gameOverLabel];

    SKLabelNode *tapToRestart = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
    tapToRestart.name = @"game_over_restart";
    tapToRestart.fontSize = 16.f;
    tapToRestart.text = @"Tap screen to restart";
    tapToRestart.position = CGPointMake(CGRectGetMidX(self.frame),
                                        CGRectGetMidY(self.frame) - 30.f);
    [self addChild:tapToRestart];

    SKAction *blinkAction = [SKAction sequence:@[
        [SKAction fadeOutWithDuration:2.f],
        [SKAction fadeInWithDuration:2.f],
    ]];

    [tapToRestart runAction:[SKAction repeatActionForever:blinkAction]];
}

#pragma mark - SKPhysicsContactDelegate Methods

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (!self.isGameOver) {
        [self _gameOver];
    }
}

@end
