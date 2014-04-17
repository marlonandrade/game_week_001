//
//  MAMonster.m
//  RunAway
//
//  Created by Marlon Andrade on 15/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAMonster.h"

#import "MAConstants.h"

@implementation MAMonster

#pragma mark - Public Interface

+ (MAMonster *)monster {
    return [[self alloc] initWithImageNamed:@"monster"];
}

#pragma mark - Designated Initializer

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
        self.name = MONSTER_NODE_NAME;

        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:12.f];
        self.physicsBody.categoryBitMask = monsterCategory;
        self.physicsBody.contactTestBitMask = playerCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.usesPreciseCollisionDetection = YES;
    }
    return self;
}

@end
