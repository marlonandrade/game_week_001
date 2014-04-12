//
//  MAMyScene.m
//  RunAway
//
//  Created by Marlon Andrade on 12/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAMyScene.h"

@interface MAMyScene()

@property (nonatomic, strong) SKSpriteNode *player;
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

        SKAction *moveAction = [SKAction moveTo:location duration:1.f];
        [self.player runAction:moveAction];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
