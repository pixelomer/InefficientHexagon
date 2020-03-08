//
//  FakeTouch.h
//  hexagonest
//
//  Created by PixelOmer on 7.03.2020.
//  Copyright © 2020 PixelOmer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UIView;

@interface FakeTouch : NSObject
@property (nonatomic, assign) BOOL leftTouch;
- (CGPoint)locationInView:(UIView *)view;
+ (instancetype)leftTouch;
+ (instancetype)rightTouch;
@end

NS_ASSUME_NONNULL_END
