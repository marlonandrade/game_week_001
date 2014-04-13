//
//  MAMyScene.m
//  RunAway
//
//  Created by Marlon Andrade on 12/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAMyScene.h"

@interface MAVector : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

+ (MAVector *)vectorWithX:(CGFloat)x Y:(CGFloat)y;
+ (MAVector *)vectorZero;
- (CGFloat)length;

@end

@implementation MAVector

+ (MAVector *)vectorWithX:(CGFloat)x Y:(CGFloat)y {
    return [[self alloc] initWithX:x Y:y];
}

+ (MAVector *)vectorZero {
    return [[self alloc] initWithX:0.f Y:0.f];
}

- (id)initWithX:(CGFloat)x Y:(CGFloat)y {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

- (MAVector *)normalize {
    return [MAVector vectorWithX:self.x / self.length
                               Y:self.y / self.length];
}

- (CGFloat)length {
    return sqrtf(self.x * self.x + self.y * self.y);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%3f, %3f]", self.x, self.y];
}

@end

@interface MAMyScene()

@property (nonatomic, strong) SKSpriteNode *player;
@property (nonatomic, assign) int playerSpeed;
@property (nonatomic, strong) MAVector *playerDirection;
@property (nonatomic, strong) SKLabelNode *scoreLabel;

@property (nonatomic, assign) int score;

@property (nonatomic, assign) CFTimeInterval lastUpdateTime;

@end

@implementation MAMyScene

#pragma mark - Setter

- (void)setScore:(int)score {
    _score = score;

    self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithWhite:0.2f alpha:1.f];

        self.playerSpeed = 100;
        self.playerDirection = [MAVector vectorZero];

        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame));
        [self addChild:self.player];

        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"04b19"];
        self.scoreLabel.fontColor = [SKColor whiteColor];
        self.scoreLabel.fontSize = 30.f;
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                               CGRectGetMaxY(self.frame) - 50.f);
        [self addChild:self.scoreLabel];

        self.score = 0;
    }
    return self;
}

- (void)_adjustPlayerDirection:(CGPoint)location {
    self.playerDirection = [[MAVector vectorWithX:location.x - self.player.position.x
                                                Y:location.y - self.player.position.y] normalize];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self _adjustPlayerDirection:[touch locationInNode:self]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self _adjustPlayerDirection:[touch locationInNode:self]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.playerDirection = [MAVector vectorZero];
}

-(void)update:(CFTimeInterval)currentTime {
    CFTimeInterval deltaTime = currentTime - self.lastUpdateTime;

    CGFloat deltaX = self.playerDirection.x * self.playerSpeed * deltaTime;
    CGFloat deltaY = self.playerDirection.y * self.playerSpeed * deltaTime;

    self.player.position = CGPointMake(self.player.position.x + deltaX,
                                       self.player.position.y + deltaY);


    self.lastUpdateTime = currentTime;
}

@end
