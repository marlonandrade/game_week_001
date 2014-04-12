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
- (CGFloat)length;

@end

@implementation MAVector

+ (MAVector *)vectorWithX:(CGFloat)x Y:(CGFloat)y {
    return [[self alloc] initWithX:x Y:y];
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
@property (nonatomic, assign) MAVector *playerDirection;
@property (nonatomic, strong) SKLabelNode *scoreLabel;

@property (nonatomic, assign) int score;

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

        self.playerSpeed = 10;

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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];

        self.playerDirection = [[MAVector vectorWithX:location.x - self.player.position.x
                                                    Y:location.y - self.player.position.y] normalize];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */

}

@end
