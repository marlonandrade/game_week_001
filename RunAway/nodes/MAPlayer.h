//
//  MAPlayer.h
//  RunAway
//
//  Created by Marlon Andrade on 13/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "MAVector.h"

@interface MAPlayer : SKSpriteNode

@property (nonatomic, assign) int moveSpeed;
@property (nonatomic, strong) MAVector *direction;

+ (MAPlayer *)player;

@end
