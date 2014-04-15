//
//  MAMyScene.m
//  RunAway
//
//  Created by Marlon Andrade on 12/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAMyScene.h"

#import "MAPlayerNode.h"
#import "MAVector.h"

@interface MAMyScene()

@property (nonatomic, strong) MAPlayerNode *player;
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

        self.player = [MAPlayerNode playerNode];
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
    self.player.direction = [[MAVector vectorWithX:location.x - self.player.position.x
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
    self.player.direction = [MAVector vectorZero];
}

-(void)update:(CFTimeInterval)currentTime {
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

@end
