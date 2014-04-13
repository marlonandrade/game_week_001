//
//  MAPlayerNode.m
//  RunAway
//
//  Created by Marlon Andrade on 13/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAPlayerNode.h"

@implementation MAPlayerNode

#pragma mark - Public Interface

+ (MAPlayerNode *)playerNode {
    return [[self alloc] initWithImageNamed:@"player"];
}

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
        self.direction = [MAVector vectorZero];
        self.moveSpeed = 100;
    }
    return self;
}

@end
