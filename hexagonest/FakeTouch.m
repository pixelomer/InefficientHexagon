//
//  FakeTouch.m
//  hexagonest
//
//  Created by PixelOmer on 7.03.2020.
//  Copyright © 2020 PixelOmer. All rights reserved.
//

#import "FakeTouch.h"

@implementation FakeTouch

static NSArray<FakeTouch *> *singletons;

+ (void)load {
	if (self == [FakeTouch class]) {
		singletons = @[
			[FakeTouch new],
			[FakeTouch new]
		];
		singletons[0].leftTouch = YES;
	}
}

+ (instancetype)leftTouch  { return singletons[0]; }
+ (instancetype)rightTouch { return singletons[1]; }

- (CGPoint)locationInView:(UIView *)view {
	return CGPointMake(_leftTouch ? CGFLOAT_MIN : CGFLOAT_MAX, 0);
}

@end
