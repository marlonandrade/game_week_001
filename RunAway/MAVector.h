//
//  MAVector.h
//  RunAway
//
//  Created by Marlon Andrade on 13/04/14.
//  Copyright (c) 2014 MarlonAndrade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAVector : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

+ (MAVector *)vectorWithX:(CGFloat)x Y:(CGFloat)y;
+ (MAVector *)vectorZero;

- (MAVector *)normalize;
- (CGFloat)length;

@end
