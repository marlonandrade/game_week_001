//
//  MAMonster.m
//  RunAway
//
//  Created by Marlon Andrade on 15/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAMonster.h"

@implementation MAMonster

#pragma mark - Public Interface

+ (MAMonster *)monster {
    return [[self alloc] initWithImageNamed:@"monster"];
}

#pragma mark - Designated Initializer

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {

    }
    return self;
}

@end
