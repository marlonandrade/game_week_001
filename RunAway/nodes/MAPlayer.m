//
//  MAPlayer.m
//  RunAway
//
//  Created by Marlon Andrade on 13/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAPlayer.h"

#import "MAConstants.h"

@implementation MAPlayer

#pragma mark - Public Interface

+ (MAPlayer *)player {
    return [[self alloc] initWithImageNamed:@"player"];
}

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
        self.name = PLAYER_NODE_NAME;

        self.direction = [MAVector vectorZero];
        self.moveSpeed = 100;

        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:12.f];
        self.physicsBody.categoryBitMask = playerCategory;
        self.physicsBody.contactTestBitMask = monsterCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.usesPreciseCollisionDetection = YES;
    }
    return self;
}

@end
