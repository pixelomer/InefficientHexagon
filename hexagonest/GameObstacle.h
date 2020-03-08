//
//  GameObstacle.h
//  hexagonest
//
//  Created by PixelOmer on 6.03.2020.
//  Copyright © 2020 PixelOmer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameObstacle : NSObject
@property (nonatomic, assign) uint8_t index;
@property (nonatomic, assign) CGFloat radius;
@end

NS_ASSUME_NONNULL_END
