//
//  MAVector.m
//  RunAway
//
//  Created by Marlon Andrade on 13/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import "MAVector.h"

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
